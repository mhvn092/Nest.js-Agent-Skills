# Configuration Standards

## Required Rules

- Use `UPPER_SNAKE_CASE` for environment variable names.
- Never hardcode credentials or secrets.
- Validate configuration before application bootstrap completes.
- Fail startup when required configuration is missing or invalid.
- Access configuration through an injected, typed configuration service or feature configuration.
- Do not read `process.env` directly in business logic.
- Never log secrets or raw variables ending in `_URI`.
- Percent-encode reserved characters in URI components.

Prefer `ConfigModule` validation using the project's established schema library (Zod, or `class-validator` + `class-transformer` + `validateSync` when compatible with installed versions).

## Connection URI Policy

Use one URI per backing-service connection as the target architecture:

```text
DATABASE_URI
REDIS_URI
RABBITMQ_URI
NATS_URI
USERS_MONGODB_URI
PAYMENTS_MONGODB_URI
```

All connection URI variables must end with `_URI`. Prefix multiple connections of the same
technology with a stable domain name.

Replacing existing split variables such as `DB_HOST` and `DB_PORT` is a `MIGRATION_TARGET`. Do not
break existing deployments without coordinating manifests, secrets, validation, and rollout.

## URI Schemes

Choose schemes according to the actual backing service and TLS topology:

| Service | Typical scheme | Decision rule |
| --- | --- | --- |
| PostgreSQL | `postgresql://` | Add `sslmode=require` when TLS is required and supported. |
| MongoDB | `mongodb://` or `mongodb+srv://` | Use SRV only when compatible SRV records exist. |
| MySQL | `mysql://` | Add driver-supported TLS options when required. |
| Redis | `redis://` or `rediss://` | Use `rediss://` when TLS terminates at Redis. |
| RabbitMQ | `amqp://` or `amqps://` | Configure heartbeat, such as `heartbeat=60`, when supported. |
| NATS | `nats://` or `tls://` | Follow the deployed NATS authentication and TLS configuration. |

Kubernetes DNS discovery does not itself require MongoDB SRV. Internal services, headless services,
operators, and managed databases may expose different connection formats.

## Runtime Environments

- Set `NODE_ENV=production` for deployed runtime environments when the application and dependencies
  are designed for production-mode execution.
- Allow local development and automated tests to use appropriate non-production values.
- Use `APP_ENV` for business-environment behavior.
- Allowed `APP_ENV` values are `local`, `dev`, `stage`, and `production`.
- Use explicit flags such as `SWAGGER_ENABLED=true|false` for independently controlled features.
- Do not infer security-sensitive behavior only from `NODE_ENV`.

Avoid binary environment flags such as `IS_MOCK` when a typed `APP_ENV` policy describes the
behavior more clearly. Preserve explicit feature flags when independent control is required.

## Environment Files

- Keep exactly one root example file using the repository's established name, preferably
  `.env.example`.
- Use dummy local values and document required keys without real credentials.
- Ignore real environment files using an appropriate `.gitignore` pattern.
- Remove committed environment-specific files only after their values have been migrated to the
  deployment secret/configuration system.

## Validation Notes

- Validate URI syntax and required schemes, not only `@IsString()`.
- Validate enums and booleans after deterministic transformation.
- Avoid unsafe implicit boolean conversion where the string `"false"` becomes truthy.
- Return actionable startup errors without exposing secret values.
