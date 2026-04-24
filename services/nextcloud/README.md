# Nextcloud

Self-hosted file sync and collaboration platform with Authelia OIDC login.

## Setup

1. Start the services: `docker compose up -d`
2. Install the "OpenID Connect Login" app from the Nextcloud app store
3. Edit `config/config.php` to add OIDC settings:

```php
'oidc_login_provider_url' => 'https://auth.${DOMAIN}',
'oidc_login_client_id' => 'nextcloud',
'oidc_login_client_secret' => 'nextcloud',
'oidc_login_button_text' => 'Login with Authelia',
'oidc_login_hide_password_form' => true,
'oidc_login_attributes' => [
    'id' => 'preferred_username',
    'name' => 'name',
    'mail' => 'email',
    'groups' => 'groups',
],
```

4. Configure in Authelia `configuration.yml` (see `auth/authelia/`)

## Environment Variables

| Variable | Description |
|----------|-------------|
| `NEXTCLOUD_DB_PASSWORD` | PostgreSQL password for nextcloud user |
| `NEXTCLOUD_ADMIN_USER` | Initial admin username |
| `NEXTCLOUD_ADMIN_PASSWORD` | Initial admin password |
| `NEXTCLOUD_DATA_DIR` | Host path for Nextcloud data |
| `NEXTCLOUD_DB_DATA_DIR` | Host path for PostgreSQL data |
