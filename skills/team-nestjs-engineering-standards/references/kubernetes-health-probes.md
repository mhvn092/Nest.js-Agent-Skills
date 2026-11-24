# Kubernetes Health Probes

Use `@nestjs/terminus` when compatible with the installed NestJS version and existing application
architecture.

## Liveness

Expose `/health/liveness` to answer whether the process and event loop are functioning.

Required behavior:

- Keep the endpoint lightweight, asynchronous, and non-blocking.
- Never check databases, brokers, caches, or downstream HTTP services.
- Return success after application initialization when the process can continue making progress.

Treat a hard memory threshold as `CONDITIONAL`, not a universal liveness rule. Restarting every pod
above an arbitrary percentage can cause restart storms. Prefer container memory limits, monitoring,
and investigation. Add a liveness memory check only when the team has evidence that the process
cannot recover and the threshold is designed against the correct container limit.

## Readiness

Expose `/health/readiness` to answer whether this pod can accept its intended traffic.

- Check only critical dependencies whose failure prevents the pod from serving that traffic.
- Do not make an optional dependency fail overall readiness.
- Use strict per-check driver timeouts.
- Return `503 Service Unavailable` when a critical readiness condition fails.
- Avoid deep or expensive queries.
- Use disk checks only when the service's request path genuinely depends on writable local disk.

Checking every downstream service can create cascading outages. Classify dependencies as critical,
optional, or asynchronous before adding them.

For Mongoose, disable command buffering for health-check connections or use driver-level operations
with strict timeouts. Tailor replica-set checks to the application's read preference and write
requirements.

## Startup

Use a Kubernetes startup probe for applications that may legitimately start slowly because of
dependency injection, warmup, or controlled migration behavior. Keep liveness and readiness delays
small after startup succeeds.

Avoid running unsafe schema migrations concurrently from every replica.

## Timeout Hierarchy

Keep outer timeouts larger than inner timeouts:

1. Kubernetes probe timeout
2. Application or Terminus aggregate timeout
3. Database, broker, or HTTP driver timeout

Leave enough time at each outer layer to serialize a failure response.

## Security

Do not rely only on the `User-Agent` header to protect probe endpoints because clients can spoof it.

Preferred controls:

1. Restrict probe access using Kubernetes NetworkPolicy, service exposure, ingress rules, or a
   dedicated management port.
2. Keep probe responses free of secrets and sensitive dependency details.
3. Add application-level restrictions only when they are compatible with how kubelet reaches pods.

Kubernetes HTTP probes do not provide a universally reliable source address or authentication
identity. Test any guard in the target cluster before enforcing it.

## Worker And Microservice Applications

Use a hybrid NestJS application with a small HTTP management endpoint when a non-HTTP worker needs
standard Kubernetes HTTP probes and this matches the service architecture.

Do not read `process.env.PROBE_PORT` directly in bootstrap code when the project uses validated
configuration. Resolve it through the configuration abstraction.
