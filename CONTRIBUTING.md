# Contributing to Grocapitus Projects

This guide covers how to contribute to any project in the Grocapitus organization.

## Before You Start

1. **Read CLAUDE.md** in the project — it explains the behavioral standards
2. **Read DEVELOPMENT.md** — it covers setup and project structure
3. **Understand the tech stack** — see TECH_STACK.md (Python, Flask, MySQL only)

## Development Workflow

### 1. Set Up Local Environment

```bash
# Clone the repo
git clone git@github.com:grocapitus/your-project.git
cd your-project

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac: or venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt

# Create local .env file
cat > .env << EOF
MYSQL_HOST=localhost
MYSQL_USER=dev_user
MYSQL_PASSWORD=dev_password
MYSQL_DATABASE=project_dev
EOF

# Start development server
python [app_name]_server.py
```

### 2. Create a Feature Branch

```bash
# Start from main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name
# or: feature/user-authentication, feature/admin-dashboard, etc.
```

### 3. Write Code Following Karpathy's 4 Principles

**Read the 4 Karpathy Principles in CLAUDE.md:**

1. **Think Before Coding** — Understand the problem before writing code
2. **Simplicity First** — Minimum code to solve the problem
3. **Surgical Changes** — Only touch what you must
4. **Goal-Driven Execution** — Define done, verify completion

**Apply them:**

```
❌ Write code, hope it works

✅ Understand the requirement
   → Ask clarifying questions
   → Plan the minimal solution
   → Write focused code
   → Test thoroughly
   → Verify with the goal
```

### 4. Add Tests (Mandatory)

**See TESTING_STANDARDS.md for complete testing methodology.**

Create `test_your_feature.py` with all 8 test parts:

```python
"""Tests for new feature."""
import pytest
import requests
from session_manager import SessionManager

# Part 1: Database Schema Tests
def test_database_schema():
    """Verify tables and columns exist."""
    # Check if table exists, columns correct type, indexes present
    pass

# Part 2: Unit Tests
def test_feature_logic():
    """Test business logic in isolation."""
    # Test function inputs/outputs, edge cases
    pass

# Part 3: GET Endpoints
def test_api_get():
    """Verify GET returns 200, valid JSON, all fields."""
    response = requests.get('http://localhost:7892/api/feature')
    assert response.status_code == 200
    data = response.json()
    assert 'data' in data
    pass

# Part 4: POST/PUT/DELETE
def test_api_post():
    """Verify POST creates resource, returns 201."""
    response = requests.post(
        'http://localhost:7892/api/feature',
        json={'name': 'test'},
        headers={'X-CSRF-Token': CSRF_TOKEN},
        cookies={'bawa_session': SESSION_ID}
    )
    assert response.status_code == 201
    pass

# Part 5: Regression Testing
def test_no_regressions():
    """Verify existing features still work."""
    # Test that old functionality wasn't broken
    pass

# Part 6: Permissions
def test_permissions():
    """Verify default-deny, correct access control."""
    # Test that non-admins can't access admin endpoints
    pass

# Part 7: Data Integrity
def test_data_integrity():
    """Verify cascading deletes, no orphaned records."""
    pass

# Part 8: UI Testing (Playwright)
@pytest.mark.asyncio
async def test_ui():
    """Verify page loads, elements present, forms work."""
    # Use Playwright to test browser behavior
    pass
```

Run tests before committing:

```bash
python -m pytest test_your_feature.py -v

# All tests must pass
# Exit code 0 = success, non-zero = failure
```

### 5. Commit with Clear Messages

```bash
git add .
git commit -m "feat: Add user authentication

- Add Google OAuth login flow
- Store session in MySQL with CSRF token
- Add /api/auth/me endpoint
- All tests passing (12/12)

Closes #42"
```

**Format:**
```
type: Brief description (< 50 chars)

Detailed explanation if needed.
- Bullet point for changes
- Another change

Closes #issue_number
```

**Types:**
- `feat:` — New feature
- `fix:` — Bug fix
- `refactor:` — Code reorganization (no behavior change)
- `test:` — Test additions/improvements
- `docs:` — Documentation
- `perf:` — Performance improvement

### 6. Push and Open Pull Request

```bash
git push origin feature/your-feature-name
```

Go to GitHub and open a PR:
- **Title**: Same as your commit message's first line
- **Description**: Link to the issue, explain what changed
- **Checklist**: Fill out the PR template

**PR template checklist:**

```markdown
- [ ] CLAUDE.md exists and complete
- [ ] All 4 Karpathy principles applied
- [ ] Tests written and passing (pytest)
- [ ] No hardcoded credentials or secrets
- [ ] Code follows project style
- [ ] Reviewed locally and works
```

## Code Review Process

### As the Author

1. **Self-review first** — Read your own PR before asking others
2. **Respond to comments** — Don't dismiss feedback; engage
3. **Request re-review** — Push fixes, ask reviewer to check again
4. **Merge when approved** — Compliance check must pass + human approval

### As the Reviewer

**Check for:**

1. **CLAUDE.md present** — Required in every PR
2. **Karpathy principles applied** — No over-engineering, surgical changes
3. **Tests written** — All 8 parts covered (schema, units, GET, POST, regression, permissions, data integrity, UI)
4. **No security issues** — No hardcoded secrets, proper input validation
5. **Code style** — Follows project conventions
6. **Performance** — No obvious N+1 queries, unnecessary loops
7. **Documentation** — Code is clear, comments explain why (not what)

**Comment template:**

```markdown
# LGTM (Looks Good To Me)

✅ CLAUDE.md present and complete
✅ All tests passing
✅ No security issues
✅ Follows project style

Ready to merge.
```

Or:

```markdown
# Changes Requested

- [ ] Add error handling for missing user (line 42)
- [ ] Simplify the nested loop on line 67 (currently O(n²))
- [ ] Add test for the new validation function

Please address and request re-review.
```

## Compliance Check (Automatic)

Every PR automatically runs the Grocapitus compliance check:

```
✅ CLAUDE.md exists
✅ Has all 4 Karpathy principles
✅ Has Haiku model policy
✅ Merge allowed
```

Or:

```
❌ CLAUDE.md missing or incomplete
❌ Merge blocked
```

**If this fails, add/fix CLAUDE.md and push again. The check will re-run.**

## Commit Best Practices

### ✅ Good Commits

```
feat: Add multi-factor authentication

- Implement TOTP verification
- Store backup codes in database
- Add /api/auth/mfa endpoint
- Update PR template with MFA checklist
- All 24 tests passing

Closes #156
```

### ❌ Bad Commits

```
fix: stuff
```

```
Update code
```

```
WIP: working on feature
```

**Every commit should be**:
- Logically complete (solves one problem)
- Revertible (git revert [commit] leaves the repo in a good state)
- Testable (you can verify the fix works)

## Testing Requirements

**Summary — see TESTING_STANDARDS.md for full details:**

| Type | Required | When |
|---|---|---|
| Unit tests | ✅ Always | Functions with logic |
| Integration tests | ✅ Always | API endpoints, DB operations |
| E2E tests | ✅ For UI changes | Page loads, forms submit, navigation |
| Regression tests | ✅ Always | Verify old features still work |
| Performance tests | ⚠️ If relevant | Large datasets, slow queries |

### Test Naming Convention

```
test_*.py                    # Test file
test_user_login()           # Test function (starts with test_)
test_user_login_success()   # Test scenario
test_user_login_failure_wrong_password()  # Detailed scenario
```

## Code Style Guide

### Python

```python
# Good: Clear, focused
def get_user_by_email(email):
    """Fetch user from database by email."""
    conn = self._get_conn()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        return cursor.fetchone()
    finally:
        conn.close()

# Bad: Over-engineered
def get_user_by_email(email, use_cache=True, retry=3, timeout=5):
    # 50 lines of logic for a simple database fetch
    pass
```

### Naming

```python
# Functions and variables: snake_case
def process_user_permissions(user_id):
    user_permissions = get_permissions(user_id)
    return user_permissions

# Classes: PascalCase
class UserManager:
    pass

# Constants: UPPER_CASE
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30
```

### Comments

```python
# Good: Explains WHY
# MySQL connection pooling is required to avoid exhausting TCP sockets
# on high-traffic endpoints (100+ req/sec)
pool = MySQLConnectionPool(pool_size=5)

# Bad: Explains WHAT (code already shows this)
# Create a connection pool with size 5
pool = MySQLConnectionPool(pool_size=5)
```

## Deployment Checklist

Before a PR can merge:

- [ ] Feature branch created from latest main
- [ ] Code follows CLAUDE.md principles
- [ ] All tests passing locally (`pytest test_*.py -v`)
- [ ] No debug print statements
- [ ] No hardcoded credentials
- [ ] .env file NOT committed
- [ ] Commit messages clear and descriptive
- [ ] PR description explains the change
- [ ] Self-review completed
- [ ] GitHub compliance check passes (CLAUDE.md validation)
- [ ] At least one other person approves
- [ ] Merge to main
- [ ] GitHub Actions runs automatically
- [ ] Sevalla Cloud redeploys (60–120 seconds)

## Common Issues

### "Compliance check failed: CLAUDE.md missing"

**Solution:** Copy CLAUDE.md from Grocapitus/Standards:

```bash
cp ../Standards/CLAUDE.md .
git add CLAUDE.md
git commit -m "Add Grocapitus behavioral standards"
git push origin feature/your-feature
```

### "Tests fail locally but pass on GitHub"

**Possible causes:**
- Different Python version
- Different MySQL version
- Hardcoded paths or credentials
- Timing issues in async code

**Fix:** Debug locally first:

```bash
python -m pytest test_*.py -v -s  # -s shows print() output
```

### "I added a feature but it's not in production"

**Checklist:**
1. Did the PR merge to main? (Check GitHub)
2. Did GitHub Actions run? (Check Actions tab)
3. Did Sevalla deploy? (Check deployment logs)

**If stuck:** Notify CTO (Neal) with the PR link.

## Questions?

- **About the workflow?** Read DEVELOPMENT.md
- **About testing?** Read TESTING_STANDARDS.md
- **About code style?** Read this document + TECH_STACK.md
- **About deployment?** Read DEPLOYMENT.md (coming soon)

---

**Last Updated:** May 19, 2026  
**Owner:** Neal Bawa (CTO)  
**Principles:** Karpathy's 4 framework — Think, Simplicity, Surgical, Goal-Driven
