# NestJS Coding Standards

## Naming

Treat these rules as `REQUIRED` for new and modified code:

- Use `kebab-case` for directories and filenames.
- Use `file-name.[type].ts`, such as `user.controller.ts`.
- Use explicit domain/role suffixes on every file, class, schema, entity, type, and injected private member (`REQUIRED` — never bare generic names):
  - Entities/schemas/tables: `UserEntity` (`user.entity.ts`), `accounts.schema.ts` — never bare `user.ts` or unsuffixed `accounts.ts`.
  - Helpers, mappers, constants, types, and runtime schemas: `*.util.ts`, `*.mapper.ts`, `*.constants.ts`, `*.types.ts`, `*.schemas.ts`.
  - Injected private members: full domain-qualified role name (`this._walletService`, `this._databaseService`, `this._configService`, `this._idempotencyService`, `this._amqpBrokerClient`) — never vague `this._service`, `this._db`, `this._config`, `this._repo`, or `this._client`.
- Use `PascalCase` for classes, interfaces, enums, and custom types.
- Do not prefix interfaces with `I`.
- Use `camelCase` for public methods, properties, functions, variables, and parameters.
- Prefix private methods and properties with `_`.
- Place private members after public and protected members.
- Use `UPPER_SNAKE_CASE` for constants and enum keys.
- Never introduce `any`; use a precise type, `unknown`, or a generic.

Async private method example:

```typescript
private async _createUser(dto: UserCreateDto): Promise<UserEntity> {
  return this._userRepository.create(dto);
}
```

Do not add `async` to a synchronous private method merely to match the example.

Apply renaming to untouched legacy code only as a `MIGRATION_TARGET`.

## Database Naming

- Use `snake_case` for newly created tables and collections.
- Prefer singular names for new storage objects when the project does not already use a conflicting
  convention.
- Keep entity properties in `camelCase`.
- Preserve existing production table and collection names unless a deliberate migration is included.

## Structure

Prefer feature modules under `src/modules/<feature>/`. Put genuinely cross-cutting code under
`src/shared/`.

Enforce strict file separation of concerns (`REQUIRED`):

- Do not mix types, module constants, Zod/runtime schemas, pure utility functions, mappers, or combined request/response DTOs into service, controller, guard, or filter files.
- Extract each concern into focused sibling files (`*.types.ts`, `*.constants.ts`, `*.schemas.ts`, `*.mapper.ts`, `*.util.ts`, and separate request vs. response DTO files).
- Promote helpers or constants used across multiple modules to `src/common/utils/` (or `src/shared/utils/`) and `src/common/constants/` (or `src/shared/constants/`).

Use root-level module or library barrels only when the project already uses barrels safely. Avoid
nested barrels that create circular dependencies. Sort exports alphabetically.

## DTOs

- Place feature DTOs under `src/modules/<module>/dto`.
- Place only genuinely shared DTOs under `src/shared/dto`.
- Prefer `[Entity][Operation][BriefDescription]Dto`, such as `UserUpdateEmailDto`.
- Use `class-validator` and `class-transformer` (or the project's established validation schema library) consistently across endpoints.
- Fully document externally exposed DTO fields with the project's OpenAPI tooling.

Generated DTOs and generated API clients are exempt from hand-authored naming rules. Change their
generator configuration or source schema instead of editing generated files.

## Controllers And OpenAPI

For public HTTP APIs using `@nestjs/swagger`:

- Treat Swagger/OpenAPI as part of the API contract, not optional documentation.
- Update Swagger/OpenAPI in the same change whenever an HTTP contract changes.
- Document operations, inputs, successful responses, and expected errors.
- Include meaningful `summary` and `description` values.
- Use the project's shared error decorators when available.
- Set explicit status codes when framework defaults do not match the contract.
- Return `204 No Content` only when the response body is intentionally empty.

An HTTP contract change includes changes to routes, methods, parameters, query values, headers,
request bodies, response bodies, status codes, error responses, authentication, authorization,
pagination, enums, defaults, nullability, examples, and deprecation state.

Keep decorators, DTO metadata, generated OpenAPI documents, runtime validation, and actual serialized
responses aligned. Do not document a response type or status code that the implementation does not
produce.

When the project generates clients from OpenAPI, regenerate or verify affected clients according to
the repository workflow. Do not edit generated clients manually.

Apply decorators in this order when compatible with the project's linting and metadata behavior:

1. Routing
2. Permission metadata
3. Guards
4. Interceptors and pipes
5. OpenAPI decorators
6. Status code

## Guards

Prefer globally applied authentication and authorization when the application architecture supports
it. Use explicit public or optional-auth decorators for exceptions.

Do not introduce a custom decorator named `@Optional()` when it can be confused with NestJS
dependency-injection `@Optional()`. Prefer an unambiguous project name such as
`@OptionalAuth()`.

## Error Handling

- Throw NestJS HTTP exceptions in HTTP application boundaries.
- For microservice transports, use the project's established RPC exception mapping.
- Do not throw bare `new Error()` for expected domain or validation failures.
- Use translation keys when the project supports i18n.
- Preserve the project's centralized exception response contract.

## Performance

- When using Mongoose, use `.lean()` for read-only queries that do not require document methods, hooks,
  virtuals, getters, or change tracking.
- Select only required fields for performance-sensitive queries.
- When using Mongoose, do not apply `.lean()` mechanically when downstream code expects hydrated documents.
- Avoid redundant plain-object conversions.
- Enforce query-driven and covering indexes (`REQUIRED`):
  - Audit every database index against actual queries, triggers, and uniqueness invariants; drop speculative or unused indexes to prevent write amplification and index bloat.
  - Prefer PostgreSQL covering indexes (`CREATE INDEX ... ON table (key_cols) INCLUDE (projected_cols)`) paired with narrowed `SELECT` projections on hot and append-only read paths to achieve Index-Only Scans.
  - Preserve PostgreSQL HOT updates by excluding frequently mutated columns (such as hot balance counters) from `INCLUDE (...)` on heavily updated tables.

## Documentation

Add JSDoc to complex public or private methods when it clarifies non-obvious behavior, contracts, or
failure modes. Do not add comments that merely restate the code.
