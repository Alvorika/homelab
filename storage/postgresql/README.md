# PostgreSQL

## Setup

1. Start: `docker compose up -d`
2. Create application users:

```bash
docker exec -it postgresql psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```

```sql
CREATE USER outline WITH PASSWORD '<password>';
GRANT ALL PRIVILEGES ON DATABASE outline_db TO outline;
ALTER DATABASE outline_db OWNER TO outline;
```

## Useful Commands

```
\du          -- List users
\conninfo    -- Connection info
\l           -- List databases
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `POSTGRES_USER` | Admin username |
| `POSTGRES_PASSWORD` | Admin password |
| `POSTGRES_DB` | Default database name |
