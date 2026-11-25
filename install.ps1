#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Project = ".",
    [switch]$Global,
    [string]$Agents = "auto",
    [string]$ZipPath = "",
    [string[]]$Only = @(),
    [string[]]$Exclude = @(),
    [switch]$NoRules,
    [switch]$Gitignore,
    [switch]$Force,
    [switch]$Prune,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TempDir = $null

try {
    $SkillsSrc = Join-Path $ScriptDir "skills"
    $TemplatesSrc = Join-Path $ScriptDir "templates"

    if ((Test-Path $SkillsSrc) -and (Test-Path $TemplatesSrc)) {
        $KitRoot = $ScriptDir
    } else {
        if (-not $ZipPath) {
            $Candidate = Join-Path $ScriptDir "nestjs-agent-kit.zip"
            if (Test-Path $Candidate) { $ZipPath = $Candidate }
        }
        if (-not $ZipPath -or -not (Test-Path $ZipPath)) {
            throw "Could not find skills/templates or nestjs-agent-kit.zip. Pass -ZipPath."
        }
        $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("nestjs-agent-kit-" + [guid]::NewGuid().ToString("N"))
        Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force
        $Nested = Join-Path $TempDir "nestjs-agent-kit"
        $KitRoot = if (Test-Path (Join-Path $Nested "skills")) { $Nested } else { $TempDir }
    }

    $SkillDirs = Get-ChildItem -Path (Join-Path $KitRoot "skills") -Directory | Where-Object {
        ($Only.Count -eq 0 -or $Only -contains $_.Name) -and
        ($Exclude.Count -eq 0 -or $Exclude -notcontains $_.Name)
    }
    if (-not $SkillDirs) {
        throw "No skills matched -Only / -Exclude filters."
    }

    $RetiredSkills = @(
        "backend-development", "codebase-design", "domain-modeling", "graphify",
        "nestjs", "nestjs-auth", "nestjs-data", "nestjs-feature",
        "nestjs-modular-monolith", "nestjs-production", "nestjs-testing", "tdd"
    )

    function Prune-Skills([string]$DestParent) {
        foreach ($Name in ($RetiredSkills + $Exclude)) {
            if (-not $Name) { continue }
            $Target = Join-Path $DestParent $Name
            if (Test-Path $Target) {
                if ($DryRun) {
                    Write-Host "  [dry-run] prune -> $Target"
                } else {
                    Remove-Item -Path $Target -Recurse -Force
                    Write-Host "  [prune] removed $Target"
                }
            }
        }
    }

    function Copy-Skill([System.IO.DirectoryInfo]$Src, [string]$DestParent) {
        $Dest = Join-Path $DestParent $Src.Name
        if ($DryRun) {
            Write-Host "  [dry-run] skill -> $Dest"
            return
        }
        New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
        if (Test-Path $Dest) { Remove-Item -Path $Dest -Recurse -Force }
        Copy-Item -Path $Src.FullName -Destination $Dest -Recurse -Force
    }

    if (-not $Global) {
        New-Item -ItemType Directory -Path $Project -Force | Out-Null
        $TargetDir = (Resolve-Path $Project).Path
        $SkillsDest = Join-Path $TargetDir ".agents\skills"

        Write-Host "Installing $($SkillDirs.Count) skills into $SkillsDest ..."
        foreach ($S in $SkillDirs) { Copy-Skill $S $SkillsDest }
        if ($Prune) { Prune-Skills $SkillsDest }

        if (-not $NoRules) {
            foreach ($Name in @("AGENTS.md", "GEMINI.md", "CLAUDE.md")) {
                $SrcFile = Join-Path $KitRoot "templates\$Name"
                $DestFile = Join-Path $TargetDir $Name
                if ((Test-Path $DestFile) -and -not $Force) {
                    Write-Host "  [skip] $Name already exists (use -Force to overwrite)"
                } elseif ($DryRun) {
                    Write-Host "  [dry-run] template -> $DestFile"
                } else {
                    Copy-Item -Path $SrcFile -Destination $DestFile -Force
                    Write-Host "  [ok] wrote $DestFile"
                }
            }
        }

        if ($Gitignore) {
            $GiPath = Join-Path $TargetDir ".gitignore"
            $Existing = if (Test-Path $GiPath) { Get-Content $GiPath -Raw } else { "" }
            if ($Existing -match "(?m)^\.agents/?\r?$") {
                Write-Host "  [skip] .gitignore already ignores .agents/"
            } elseif ($DryRun) {
                Write-Host "  [dry-run] append AI tooling ignore block to $GiPath"
            } else {
                $Snippet = Get-Content (Join-Path $KitRoot "templates\gitignore.snippet") -Raw
                Add-Content -Path $GiPath -Value "`n$Snippet"
                Write-Host "  [ok] updated $GiPath"
            }
        }
        Write-Host "Done."
    } else {
        $HomeDir = $HOME
        $Targets = New-Object System.Collections.Generic.List[string]
        $AgentMap = @{
            antigravity = Join-Path $HomeDir ".gemini\config\skills"
            gemini      = Join-Path $HomeDir ".gemini\config\skills"
            agents      = Join-Path $HomeDir ".agents\skills"
            claude      = Join-Path $HomeDir ".claude\skills"
            codex       = Join-Path $HomeDir ".codex\skills"
        }

        if ($Agents -eq "auto") {
            $Targets.Add($AgentMap.antigravity)
            $Targets.Add($AgentMap.agents)
            if (Test-Path (Join-Path $HomeDir ".claude")) { $Targets.Add($AgentMap.claude) }
            if (Test-Path (Join-Path $HomeDir ".codex")) { $Targets.Add($AgentMap.codex) }
        } elseif ($Agents -eq "all") {
            @("antigravity", "agents", "claude", "codex") | ForEach-Object { $Targets.Add($AgentMap[$_]) }
        } else {
            $Agents.Split(",") | ForEach-Object {
                $Key = $_.Trim().ToLowerInvariant()
                if (-not $AgentMap.ContainsKey($Key)) { throw "Unknown agent target: $Key" }
                if (-not $Targets.Contains($AgentMap[$Key])) { $Targets.Add($AgentMap[$Key]) }
            }
        }

        foreach ($T in $Targets) {
            Write-Host "Installing $($SkillDirs.Count) skills into $T ..."
            foreach ($S in $SkillDirs) { Copy-Skill $S $T }
            if ($Prune) { Prune-Skills $T }
        }
        Write-Host "Done."
    }
} finally {
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Path $TempDir -Recurse -Force
    }
}
