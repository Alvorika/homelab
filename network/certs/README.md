# Certificates (mkcert)

Self-signed CA-based certificate management for internal services.

## Setup

```bash
# 1. Initialize the local CA
./cert.sh --init-ca

# 2. Install root CA on all devices:
#    Linux:
sudo cp mkcert_data/ca/rootCA.pem /usr/local/share/ca-certificates/myRootCA.crt
sudo update-ca-certificates
#    Windows: run cert.bat (Admin) with rootCA.pem in same directory

# 3. Generate certs for all domains in domains.txt
./cert.sh --update

# 4. Add a new domain
./cert.sh --add new-service.lab.internal
```

## Certificate Sync

`get-cert.sh` runs on the app server to pull updated certs from the gateway via SSH.

## Directory Structure

```
certs/
├── docker-compose.yml
├── cert.sh              # Management script
├── get-cert.sh          # Remote sync script
├── domains.txt          # Domain list
└── mkcert_data/
    ├── ca/              # CA root key + cert
    └── certs/           # Generated certificates
```
