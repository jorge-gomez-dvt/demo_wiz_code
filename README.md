# Vulnerable Demo Application

> **WARNING: This repository contains intentional security vulnerabilities for demonstration purposes with Wiz Code security scanning. DO NOT use any of this code in production.**

## Purpose

This repository is designed to showcase Wiz Code's vulnerability detection capabilities across multiple languages, frameworks, and infrastructure-as-code technologies.

## Vulnerabilities Included

### Dependency Vulnerabilities (SCA)
| File | Technology | Notable CVEs |
|------|-----------|--------------|
| `requirements.txt` | Python | CVE in Django, Flask, Pillow, PyYAML, pycrypto |
| `package.json` | Node.js | CVE in lodash, axios, handlebars, serialize-javascript |
| `pom.xml` | Java/Maven | Log4Shell (CVE-2021-44228), Spring4Shell, Struts, XStream |
| `Gemfile` | Ruby | CVEs in Rails, Devise, Nokogiri |
| `go.mod` | Go | CVEs in jwt-go, opencontainers/runc |
| `Pipfile` | Python | Same as requirements.txt |

### Secret Leakage
- `.env` — AWS keys, Stripe keys, JWT secrets, DB passwords
- `config/secrets.yaml` — All production secrets in YAML
- `Dockerfile` — Secrets in ENV directives
- `docker-compose.yml` — Secrets in environment section
- `.github/workflows/deploy.yml` — Secrets hardcoded in CI/CD
- `main.tf` — AWS credentials in Terraform provider
- `k8s/deployment.yaml` — Secrets in Kubernetes env vars

### Code Vulnerabilities (SAST)
- **SQL Injection** — `app.py`, `app.js`, `UserController.java`, `main.go`
- **Command Injection** — `app.py`, `app.js`, `UserController.java`, `main.go`
- **XSS** — `app.py`, `app.js`
- **Path Traversal** — `app.py`, `app.js`, `UserController.java`, `main.go`
- **SSRF** — `app.py`, `app.js`, `main.go`
- **Insecure Deserialization** — `app.py`, `UserController.java`
- **XXE** — `UserController.java`
- **Broken Crypto** — `crypto_utils.py` (MD5, SHA1, DES, RC4, ECB mode)
- **JWT Algorithm None** — `app.js`
- **Unsafe YAML load** — `app.py`
- **Prototype Pollution** — `app.js`

### Infrastructure Misconfigurations
- **Docker** — Root user, privileged mode, host mounts, secrets in ENV
- **Kubernetes** — Privileged pods, cluster-admin RBAC, host path mounts
- **Terraform/AWS** — S3 public access, security groups open to 0.0.0.0/0, RDS publicly accessible, no encryption, over-permissive IAM
- **nginx** — SSLv2/SSLv3, weak ciphers, directory listing, no security headers

## File Structure

```
.
├── app.py                          # Python Flask app (SAST vulns)
├── app.js                          # Node.js Express app (SAST vulns)
├── main.go                         # Go Gin app (SAST vulns)
├── UserController.java             # Java Spring controller (SAST vulns)
├── crypto_utils.py                 # Weak cryptography examples
├── requirements.txt                # Vulnerable Python deps
├── package.json                    # Vulnerable Node.js deps
├── pom.xml                         # Vulnerable Java deps (Log4Shell!)
├── Gemfile                         # Vulnerable Ruby deps
├── go.mod                          # Vulnerable Go deps
├── Pipfile                         # Vulnerable Python deps
├── Dockerfile                      # Insecure Dockerfile
├── docker-compose.yml              # Insecure compose config
├── nginx.conf                      # Insecure nginx config
├── main.tf                         # Insecure Terraform
├── .env                            # Secrets file (should never be committed)
├── config/
│   ├── database.py                 # Hardcoded DB credentials
│   └── secrets.yaml                # All secrets in plaintext
├── k8s/
│   └── deployment.yaml             # Insecure K8s manifests
├── terraform/
│   ├── s3.tf                       # Public S3 buckets
│   └── iam.tf                      # Over-permissive IAM
└── .github/
    └── workflows/
        └── deploy.yml              # Secrets in CI/CD pipeline
```
