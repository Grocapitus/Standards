# Grocapitus Technology Stack — Mandatory Standards

This document defines the ONLY approved technologies for Grocapitus projects. **Deviations require explicit CTO approval and must be documented in the project README.**

## Language

| Technology | Status | Usage |
|---|---|---|
| Python 3.9+ | ✅ **ONLY** | All backend services, scripts, data processing |
| Node.js | ❌ **PROHIBITED** | Never use |
| TypeScript | ❌ **PROHIBITED** | Never use |
| Go | ❌ **Not approved** | Request approval if needed |
| Rust | ❌ **Not approved** | Request approval if needed |

### Why Python Only?

- **Consistency**: All developers learn one ecosystem
- **Data science**: We use pandas, numpy, scipy for financial modeling
- **Claude integration**: Anthropic SDK is Python-first; all AI work uses Python
- **Deployment**: Sevalla Cloud has standardized Python runtime

---

## Backend Framework

| Framework | Status | Usage |
|---|---|---|
| Flask | ✅ **ONLY** | HTTP servers, REST APIs, web services |
| Django | ❌ **PROHIBITED** | Use Flask instead (lighter weight) |
| FastAPI | ❌ **Not approved** | Flask is preferred for simplicity |
| Others | ❌ **PROHIBITED** | No Express, Koa, Actix, Fastify, etc. |

### Why Flask?

- **Minimal**: No magic, explicit is better than implicit
- **Composable**: Small, focused middleware
- **Learnable**: New developers ramp up quickly
- **Proven**: Used in production at Grocapitus since [date]

---

## Database

| System | Status | Usage | Details |
|---|---|---|---|
| MySQL 8.0+ | ✅ **ONLY** | All persistent data | On Sevalla Cloud only |
| PostgreSQL | ❌ **PROHIBITED** | — | Use MySQL instead |
| MongoDB | ❌ **PROHIBITED** | — | No NoSQL; all data is relational |
| Redis | ✅ **Allowed** | Caching, sessions (optional) | Only for performance optimization |
| SQLite | ❌ **Development only** | Local testing only | Never in production |

### Why MySQL on Sevalla?

- **Managed service**: Sevalla handles backups, replication, failover
- **Consistency**: All projects use the same DB and cloud provider
- **Schema enforcement**: SQL schemas are version-controlled and reviewed
- **Security**: Credentials managed via Sevalla secrets, not hardcoded

### Connection Details

- **Host**: Provided by Sevalla environment variables
- **Port**: 3306 (standard MySQL)
- **Connection pooling**: Use `mysql.connector.pooling.MySQLConnectionPool` (see `user_manager.py` for example)
- **Credentials**: Via `.env` file (see DEVELOPMENT.md) or Sevalla environment variables

---

## Cloud Provider

| Provider | Status | Usage |
|---|---|---|
| Sevalla Cloud | ✅ **ONLY** | All deployments |
| AWS | ❌ **PROHIBITED** | Use Sevalla instead |
| Google Cloud | ❌ **PROHIBITED** | Use Sevalla instead |
| Azure | ❌ **PROHIBITED** | Use Sevalla instead |
| Heroku | ❌ **PROHIBITED** | Use Sevalla instead |

### Why Sevalla?

- **Managed**: No DevOps overhead
- **Integrated**: Automatic deployment via GitHub Actions
- **Secrets management**: Environment variables stored securely
- **Consistency**: All projects deploy the same way

---

## Authentication

| Method | Status | Usage | Details |
|---|---|---|---|
| Google OAuth | ✅ **ONLY** | User login | OAuth2 flow, credentials in outputs/oauth_config.json |
| Local sessions | ✅ **For APIs** | Server-side session storage | MySQL-backed (see SessionManager) |
| API Keys | ❌ **PROHIBITED** | — | Use Google OAuth instead |
| Basic Auth | ❌ **PROHIBITED** | — | Never send passwords in headers |
| Custom tokens | ❌ **PROHIBITED** | — | Use Google OAuth or session cookies |

### Why Google OAuth?

- **Security**: Delegates auth to Google (industry standard)
- **User experience**: No password resets or recovery
- **Centralized**: All users managed through Google Workspace
- **Audit trail**: Google logs all access

---

## Deployment Pipeline

| Stage | Tool | Status |
|---|---|---|
| Code commit | Git | ✅ **Only** version control |
| CI/CD | GitHub Actions | ✅ **Only** CI/CD system |
| Testing | pytest | ✅ **Only** test framework |
| Cloud deploy | Sevalla | ✅ **Only** production target |

### Pipeline Flow

```
Code commit to main
  ↓
GitHub Actions (.github/workflows/release.yml) triggers
  ↓
Run Python syntax check & import validation
  ↓
Run test suite (all tests must pass)
  ↓
On success: Sevalla Cloud auto-deploys live
  ↓
Live in 60–120 seconds
```

---

## Frontend

| Technology | Status | Usage |
|---|---|---|
| HTML5 | ✅ **ONLY** | Page markup |
| CSS3 | ✅ **ONLY** | Styling |
| JavaScript (vanilla) | ✅ **ONLY** | Interactivity (no frameworks) |
| React | ❌ **PROHIBITED** | Use vanilla JS instead |
| Vue | ❌ **PROHIBITED** | Use vanilla JS instead |
| Angular | ❌ **PROHIBITED** | Use vanilla JS instead |
| npm | ❌ **PROHIBITED** | Never install Node packages |
| Build tools | ❌ **PROHIBITED** | No webpack, esbuild, vite, parcel |

### Why Vanilla JavaScript?

- **No build step**: Direct deployment, no compilation
- **No dependencies**: Fewer security vulnerabilities
- **Small bundles**: Fast load times
- **Portable**: Minimal dependencies for Sevalla deployment

---

## Testing Framework

| Framework | Status | Usage |
|---|---|---|
| pytest | ✅ **ONLY** | Unit and integration tests |
| unittest | ❌ **Not preferred** | Use pytest instead |
| Jest | ❌ **PROHIBITED** | No JavaScript testing |
| Selenium | ❌ **Not preferred** | Use Playwright (see TESTING_STANDARDS.md) |
| Playwright | ✅ **For E2E tests** | End-to-end browser automation |

### Test Command

```bash
python -m pytest test_*.py -v
```

All tests must pass before merge.

---

## Configuration Management

| Method | Status | Usage |
|---|---|---|
| `.env` files | ✅ **Local development** | Load via `python-dotenv` |
| Sevalla secrets | ✅ **Production** | Environment variables injected at runtime |
| `.env` in git | ❌ **PROHIBITED** | Always in `.gitignore` |
| Hardcoded config | ❌ **PROHIBITED** | Never in source code |

### Example: .env File (Local Development)

```bash
MYSQL_HOST=localhost
MYSQL_USER=dev_user
MYSQL_PASSWORD=dev_password
MYSQL_DATABASE=dashboards_dev
GOOGLE_OAUTH_CLIENT_ID=...
GOOGLE_OAUTH_CLIENT_SECRET=...
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
```

**Never commit this file.** Sevalla provides these variables at runtime in production.

---

## Logging

| Library | Status | Usage |
|---|---|---|
| Python `logging` | ✅ **ONLY** | Standard library logging |
| print() | ⚠️ **For debugging** | Remove before merge |
| Third-party loggers | ❌ **PROHIBITED** | Use stdlib only |

**See LOGGING.md for complete logging standards and best practices.**

---

## Forbidden Technologies (Complete List)

**These are explicitly prohibited. Using them requires CTO approval and a documented exception.**

- ❌ Node.js / npm / TypeScript
- ❌ Django, FastAPI, Fastly, others (Flask only)
- ❌ PostgreSQL, MongoDB, Redis (MySQL primary; Redis optional for caching)
- ❌ AWS, GCP, Azure, Heroku (Sevalla only)
- ❌ React, Vue, Angular, Svelte, Preact (vanilla JS only)
- ❌ webpack, esbuild, Vite, Parcel, Babel (no build tools)
- ❌ Selenium (use Playwright for E2E)
- ❌ API Keys, Basic Auth, JWT (Google OAuth or sessions)

---

## Rationale: Why These Constraints?

1. **Single language** (Python): Reduces context switching, improves team knowledge sharing
2. **Single framework** (Flask): Smaller learning curve, consistency across projects
3. **Single database** (MySQL on Sevalla): Managed service, consistent backups/security
4. **Single cloud** (Sevalla): One deployment pipeline, one set of credentials, unified operations
5. **Single auth** (Google OAuth): Industry standard, no password management burden
6. **Vanilla JS**: No build step, minimal deployment friction, portable
7. **No Node.js**: Reduces package bloat, eliminates npm security risk, avoids dual-language teams

---

## Requesting an Exception

**If you need to use a technology not on this list:**

1. Document the specific requirement (why this technology is essential)
2. Compare against approved alternatives (why the approved one doesn't work)
3. Get CTO approval and commit a summary to the repo's README
4. Add to this file with approval date and justification

**Example approved exception:**

```markdown
### Exception: PostgreSQL for Analytics (Approved 2026-05-19)
Reason: PostGIS for geospatial queries in investment-risk dashboard
Justification: MySQL spatial indexes insufficient for 10M+ point queries
Approval: CTO Neal Bawa
Status: investment-risk dashboard only; rest of org uses MySQL
```

---

## Checklist for New Projects

When creating a new project in Grocapitus:

- [ ] Backend: Python 3.9+ with Flask
- [ ] Database: MySQL on Sevalla Cloud
- [ ] Frontend: HTML5, CSS3, vanilla JavaScript
- [ ] Auth: Google OAuth
- [ ] Testing: pytest for unit tests, Playwright for E2E
- [ ] Deployment: GitHub Actions → Sevalla Cloud
- [ ] Config: .env file (development), Sevalla secrets (production)
- [ ] Logging: Python stdlib only
- [ ] No Node.js, no npm, no build tools
- [ ] CLAUDE.md present with all 4 Karpathy principles + Haiku policy

---

**Last Updated:** May 19, 2026  
**Owner:** Neal Bawa (CTO)  
**Status:** Mandatory for all Grocapitus projects
