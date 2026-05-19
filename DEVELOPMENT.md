# Grocapitus Development Standards

This document defines the standard file structure, development setup, and local development workflow for all Grocapitus projects.

## Project Structure

All projects follow this standardized directory layout:

```
your-project/
├── .claude/                      # Claude Code project config
│   └── settings.json             # Settings with hooks, model policy
├── .devcontainer/                # GitHub Codespaces configuration
│   ├── devcontainer.json         # Container definition
│   ├── postCreateCommand.sh      # Runs on container creation
│   └── setup.sh                  # Environment setup script
├── .github/                       # GitHub configuration
│   └── workflows/
│       └── standards.yml          # Grocapitus compliance check (inherited from Standards repo)
├── .gitignore                    # Standard ignore rules
├── outputs/                      # Generated files and app content
│   ├── index.html                # Main HTML files for apps
│   ├── oauth_config.json         # Google OAuth credentials
│   └── [app-specific files]/
├── projects/                     # Sub-projects or data stores (optional)
├── CLAUDE.md                     # Behavioral standards (copy from Grocapitus/Standards)
├── README.md                     # Project documentation
├── requirements.txt              # Python dependencies (see below)
├── [app_name]_server.py          # Main Flask application
├── user_manager.py               # (if managing users) User and permission management
├── session_manager.py            # (if managing sessions) Session storage
├── [helper_module].py            # Domain-specific helper modules
├── [helper_module]_helper.py     # Utility functions
└── test_*.py                     # Test files (one per module tested)
```

---

## Required Files

### 1. CLAUDE.md (Mandatory)

**Copy from:** `Grocapitus/Standards/CLAUDE.md`

This file is **required** in every project. It contains:
- The 4 Karpathy behavioral principles
- Haiku model policy
- Project-specific development guidelines

**GitHub compliance check enforces this file on every PR.**

### 2. requirements.txt

**Standard structure:**

```
python-dotenv
mysql-connector-python
requests
google-auth
[project-specific-packages]
```

**Guidelines:**
- Pin major versions: `python-dotenv==1.0.0`
- No `== versions for major libs (let patch versions float): `requests>=2.28.0`
- One package per line
- Alphabetical order for readability
- Total dependencies: < 20 packages (fewer is better)

### 3. .env (Local Development Only)

**Never commit this file.** Add to `.gitignore`:

```bash
MYSQL_HOST=localhost
MYSQL_USER=dev_user
MYSQL_PASSWORD=dev_password
MYSQL_DATABASE=project_dev
GOOGLE_OAUTH_CLIENT_ID=...
GOOGLE_OAUTH_CLIENT_SECRET=...
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
```

**Sevalla environment variables** (production): Set via Sevalla Cloud dashboard, injected at runtime.

### 4. .gitignore

**Minimum required entries:**

```
# Python
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/
venv/
env/
.venv

# IDE
.vscode/
.idea/
*.swp
*.swo

# Credentials (CRITICAL)
.env
.env.local
credentials.json
token.pickle
outputs/oauth_config.json
outputs/gmail_token.json
outputs/*.db

# OS
.DS_Store
Thumbs.db

# Project-specific
outputs/tiller_data.db
projects/class-reminder-app/data/
```

---

## Python Dependencies

### Managing Packages

**Install locally for development:**

```bash
pip install -r requirements.txt
```

**Add a new dependency:**

```bash
pip install new-package
pip freeze > requirements.txt
# Then edit requirements.txt to pin versions appropriately
```

### Approved Core Libraries

| Package | Purpose | Why |
|---|---|---|
| python-dotenv | Load .env variables | Standard for config management |
| mysql-connector-python | MySQL connection | Official MySQL driver |
| requests | HTTP client | Standard library for API calls |
| google-auth | Google OAuth | Official Google authentication |
| google-auth-oauthlib | Google OAuth flow | Handles OAuth callback |
| google-api-python-client | Google Workspace APIs | Gmail, Drive, Calendar |
| twilio | SMS/WhatsApp | Standard SMS provider |
| icalendar | Calendar parsing | RFC 5545 compliance |
| python-dateutil | Date utilities | Timezone handling |
| reportlab | PDF generation | Industry standard for PDFs |
| anthropic | Claude API | Official Anthropic SDK |
| youtube-transcript-api | YouTube transcripts | Lightweight transcript retrieval |
| yt-dlp | Video download | Best video downloader |
| pytest | Testing | Standard test framework |
| playwright | E2E testing | Modern browser automation |

**No third-party loggers, no ORM frameworks, no async frameworks.**

---

## Local Development Workflow

### Step 1: Clone and Setup

```bash
git clone git@github.com:grocapitus/your-project.git
cd your-project

# Set up Python environment
python3 -m venv venv
source venv/bin/activate  # or: venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt

# Create .env for local development
cp .env.example .env  # or create manually
# Edit .env with your local MySQL and OAuth credentials
```

### Step 2: Google OAuth Setup (Local Development)

If your project uses Google OAuth:

1. Go to `console.cloud.google.com`
2. Create/select project
3. Create OAuth 2.0 credentials (Web application)
4. Add `http://localhost:7892/callback` to authorized redirect URIs
5. Download credentials as JSON
6. Save to `outputs/oauth_config.json` (in `.gitignore`, won't be committed)

### Step 3: Database Setup

**For projects using MySQL:**

```bash
# Ensure MySQL is running locally or on Sevalla dev instance
# Run any migration/schema setup script (e.g., phase1_setup.py)

python phase1_setup.py

# Verify connection:
python3 -c "from user_manager import UserManager; m = UserManager(); print('Connected')"
```

### Step 4: Start Server

```bash
python [app_name]_server.py
```

Server runs on `http://localhost:7892` by default.

**Important:** Use the GitHub Codespaces forwarded URL for access from iPad/external devices.

### Step 5: Run Tests

```bash
# Run all tests
python -m pytest test_*.py -v

# Run specific test
python -m pytest test_admin.py::test_user_permissions -v

# Run with coverage
python -m pytest test_*.py --cov=. --cov-report=html
```

**All tests must pass before committing.**

---

## Server Implementation

### Main Server File Pattern (Flask)

**Example:** `dashboard_server.py`

```python
from flask import Flask, jsonify, request, render_template, session
import os
from dotenv import load_dotenv
from user_manager import UserManager
from session_manager import SessionManager

load_dotenv()

app = Flask(__name__, static_folder='outputs', static_url_path='/')

# Initialize managers
_user_manager = None
_session_manager = SessionManager(use_db=True)

def _get_user_manager():
    global _user_manager
    if not _user_manager:
        _user_manager = UserManager(
            host=os.getenv('MYSQL_HOST'),
            user=os.getenv('MYSQL_USER'),
            password=os.getenv('MYSQL_PASSWORD'),
            database=os.getenv('MYSQL_DATABASE')
        )
    return _user_manager

# Routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/auth/me')
def get_current_user():
    # Implement session/user logic
    pass

# Error handlers
@app.errorhandler(404)
def not_found(e):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def server_error(e):
    return jsonify({'error': 'Server error'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7892, debug=False)
```

### Connection Pooling Pattern

**Always use `MySQLConnectionPool` for database connections:**

```python
from mysql.connector.pooling import MySQLConnectionPool

class UserManager:
    def __init__(self, host, user, password, database):
        self._pool = MySQLConnectionPool(
            pool_name="user_pool",
            pool_size=5,
            host=host,
            user=user,
            password=password,
            database=database
        )
    
    def _get_conn(self):
        return self._pool.get_connection()
    
    def some_method(self):
        conn = self._get_conn()
        try:
            # Do work
        finally:
            conn.close()  # Returns connection to pool
```

**Never do `mysql.connector.connect()` directly—always use a pool.**

---

## Testing Requirements

See `TESTING_STANDARDS.md` for complete testing methodology. **TL;DR:**

```bash
# Must create test file before pushing
python test_your_feature.py

# All tests must pass
python -m pytest test_*.py -v

# Include all 8 test parts:
# 1. Database schema, 2. Units, 3. GET endpoints, 4. POST/PUT/DELETE,
# 5. Regressions, 6. Permissions, 7. Data integrity, 8. UI (Playwright)
```

---

## File Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Flask server | `{app_name}_server.py` | `dashboard_server.py` |
| Business logic | `{module_name}.py` | `user_manager.py` |
| Helpers | `{feature}_helper.py` | `google_drive_helper.py` |
| Tests | `test_{module_name}.py` | `test_user_manager.py` |
| HTML templates | `{feature}.html` | `home.html`, `admin.html` |
| Stylesheets | `{feature}.css` | `home.css` |
| JavaScript | `{feature}.js` | `home.js` (inline in HTML preferred) |
| Migrations | `add_{feature}.py` | `add_foreign_key.py` |
| Utility scripts | `{action}_{object}.py` | `migrate_lease_builder.py` |

---

## Code Style

### Python Style Guide

Follow PEP 8 with these exceptions:

| Rule | Grocapitus | Why |
|---|---|---|
| Line length | 100 characters | Balance readability and screen space |
| Docstrings | One-liners only | Keep code concise; comments for non-obvious why |
| Imports | Group: stdlib, third-party, local | Standard PEP 8 |
| Naming | snake_case for functions/vars | Python convention |

### Example: Python Code Structure

```python
# Imports (grouped)
import os
import json
from datetime import datetime

import mysql.connector
import requests
from dotenv import load_dotenv

from user_manager import UserManager

# Module docstring (if needed)
"""Handles the application startup and configuration."""

# Constants
DEBUG = os.getenv('DEBUG', 'False') == 'True'
MAX_RETRIES = 3

# Functions
def setup_database():
    """Initialize database connection pool."""
    # Implementation
    pass

# Classes
class AppManager:
    """Manages application state."""
    
    def __init__(self):
        self.state = {}
    
    def add_app(self, name):
        """Register a new app."""
        self.state[name] = {'created': datetime.now()}
```

### HTML/CSS/JavaScript

- Vanilla JavaScript: Inline in `<script>` tags (no separate .js files unless >500 lines)
- CSS: Inline in `<style>` tags or `<link>` to external file
- No class frameworks; no build tools
- Indentation: 2 spaces (HTML standard)

---

## Git Workflow

### Branch Strategy

```
main (always deployable)
  ↑
feature/feature-name (your work)
  ↓
Pull Request → Code Review → Merge
```

### Commit Message Format

```
Type: Brief description (< 50 chars)

Detailed explanation if needed (< 72 chars per line).
Reference issue if applicable: Closes #123

- Bullet point for changes
- Another change
```

**Types:** `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `perf:`

### Before Pushing

```bash
# Run tests locally
python -m pytest test_*.py -v

# All tests must pass
# If any test fails, fix before pushing

# Check code style
python -m pytest --cov=. test_*.py  # Optional: coverage report

# Push to feature branch
git push origin feature/your-feature

# Create PR on GitHub (includes compliance check automatically)
```

---

## Troubleshooting

| Issue | Solution |
|---|---|
| "ModuleNotFoundError: No module named 'X'" | Run `pip install -r requirements.txt` |
| "MySQL connection refused" | Check `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD` in .env |
| "OAuth redirect_uri_mismatch" | Add `http://localhost:7892/callback` to Google Cloud Console |
| "Tests fail with 'CSRF validation failed'" | Use valid session tokens from running server; see TESTING_STANDARDS.md |
| "Port 7892 already in use" | Kill existing process: `lsof -ti :7892 \| xargs kill -9` |

---

## Deployment Checklist

Before pushing to main for deployment:

- [ ] All tests pass locally (`pytest test_*.py -v`)
- [ ] No debug print statements
- [ ] No hardcoded credentials
- [ ] .env file NOT committed (in .gitignore)
- [ ] CLAUDE.md present and complete
- [ ] requirements.txt up to date
- [ ] GitHub PR created (triggers compliance check)
- [ ] Compliance check passes (includes CLAUDE.md validation)
- [ ] Code review completed
- [ ] Merge to main
- [ ] GitHub Actions runs automatically
- [ ] Sevalla Cloud deploys within 60–120 seconds

---

**Last Updated:** May 19, 2026  
**Owner:** Neal Bawa (CTO)  
**Reference:** See TECH_STACK.md for approved technologies
