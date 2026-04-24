# Backup And Restore

Backups should include both application data and the secrets required to decrypt or authenticate that data.

## What To Back Up

| Area | Data |
|------|------|
| Environment | `.env`, rendered configs, deployment notes |
| Certificates | mkcert root CA, service certs, private keys |
| Authelia | `configuration.yml`, users database, secrets, SQLite storage |
| Gitea | repositories, SQLite database, `app.ini`, LFS data |
| PostgreSQL | logical dumps and volume snapshots |
| MinIO | bucket data and access key records |
| Nextcloud | app files, user files, database, `config.php` |
| Outline | PostgreSQL database, MinIO bucket, `docker.env` |
| OpenWebUI | `open_webui_data` volume |
| JupyterHub | Hub database, user `jupyterhub_data` directories |
| Samba | private and public share directories |

## PostgreSQL

Create a logical dump:

```bash
docker exec postgresql pg_dumpall -U "${POSTGRES_USER}" > postgres-all.sql
```

Restore:

```bash
docker exec -i postgresql psql -U "${POSTGRES_USER}" < postgres-all.sql
```

## Gitea

Back up:

- `services/gitea/data`
- rendered `app.ini`
- repositories and LFS data under the configured Gitea data path

If using the template SQLite setup, stop Gitea before taking a filesystem copy.

## MinIO

Use MinIO client or storage-level snapshots. Verify the `outline` bucket and any access-key-dependent applications after restore.

## Nextcloud

Back up:

- `NEXTCLOUD_DATA_DIR`
- `NEXTCLOUD_DB_DATA_DIR` or the external database dump
- `config/config.php`

Put Nextcloud into maintenance mode before a hot backup when possible.

## Authelia

Back up:

- `auth/authelia/data/config`
- `auth/authelia/data/secrets`
- rendered Authelia config

Without the same secrets and OIDC key material, existing sessions and OIDC integrations may break after restore.

## Restore Order

1. Restore `.env`, secrets, and certificate material.
2. Restore Docker volumes or host directories.
3. Start storage services.
4. Restore databases.
5. Start Authelia.
6. Start application services.
7. Verify OIDC login, file uploads, and service-specific health.

## Backup Checks

Periodically test a restore on a separate machine or disposable VM. A backup that has never been restored is only an assumption.

