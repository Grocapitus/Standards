# Grocapitus Logging Standards

All projects use Python's standard `logging` library. No third-party logging frameworks.

## Basic Setup

**In your main server file:**

```python
import logging
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
    ]
)

# Get logger for your module
logger = logging.getLogger(__name__)

# Use it
logger.info("Server started on port 7892")
logger.error("Failed to connect to database")
logger.debug("User data: %s", user_dict)
```

## Log Levels

| Level | When to Use | Example |
|---|---|---|
| `DEBUG` | Detailed info for developers | Variable values, loop iterations |
| `INFO` | General informational messages | Server startup, successful operations |
| `WARNING` | Unexpected but recoverable | Retrying API call, missing optional config |
| `ERROR` | Errors that don't stop the app | Failed DB transaction, API timeout |
| `CRITICAL` | Fatal errors | Can't connect to database at startup |

## Logging Rules

### ✅ DO

- ✅ Log at entry/exit of important functions
- ✅ Log errors with context (what was attempted, why it failed)
- ✅ Use structured data: `logger.info("User %s logged in from %s", email, ip_address)`
- ✅ Log API responses for debugging
- ✅ Log database query performance (query time > 1 second)
- ✅ Log security events (login, access denial, permission changes)

### ❌ DON'T

- ❌ Log passwords, API keys, or credentials
- ❌ Log full request/response bodies (log summaries instead)
- ❌ Log PII (Personal Identifiable Information) unless necessary
- ❌ Use `print()` in production code (only `logger.*()`)
- ❌ Create multiple root loggers
- ❌ Log the same event multiple times (deduplicate)

## Examples

### Database Operations

```python
logger.info("Fetching user: %s", email)
cursor = conn.cursor()
start = time.time()
cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
elapsed = time.time() - start
if elapsed > 1.0:
    logger.warning("Slow query: SELECT user took %.2f seconds", elapsed)
result = cursor.fetchone()
if not result:
    logger.warning("User not found: %s", email)
else:
    logger.info("User found: %s", email)
```

### API Calls

```python
logger.info("Calling Google Drive API for file: %s", file_id)
try:
    response = google_client.files().get(fileId=file_id).execute()
    logger.info("Successfully retrieved file from Drive: %s", file_id)
except Exception as e:
    logger.error("Failed to retrieve file %s: %s", file_id, str(e))
    raise
```

### Authentication/Authorization

```python
logger.info("Login attempt: %s from IP %s", email, request.remote_addr)

if not user_manager.user_exists(email):
    logger.warning("Login failed - user not found: %s from IP %s", email, request.remote_addr)
    return jsonify({'error': 'Invalid credentials'}), 401

if not user_manager.user_can_access_app(email, app_name):
    logger.warning("Access denied - user %s not permitted for %s", email, app_name)
    return jsonify({'error': 'Access denied'}), 403

logger.info("Login successful: %s", email)
```

### Errors with Context

```python
# BAD - no context
logger.error("Query failed")

# GOOD - includes what was attempted
logger.error("Failed to insert app: %s - error: %s", app_name, str(e))

# GOOD - includes decision
logger.error("Failed to fetch %s from Google Drive (attempt %d of %d), will retry in 5s", 
             file_id, attempt, max_attempts)
```

## Configuration for Different Environments

### Local Development

```python
logging.basicConfig(level=logging.DEBUG)  # See everything
```

### Production (Sevalla Cloud)

```python
logging.basicConfig(level=logging.INFO)  # Only important events
# Error handling/alerting via application monitoring (to be added)
```

### Testing

```python
# Suppress logs during test runs
logging.getLogger().setLevel(logging.CRITICAL)
```

## Common Patterns

### Function Entry/Exit

```python
def process_user_permissions(user_id):
    logger.info("Processing permissions for user: %s", user_id)
    try:
        result = _calculate_permissions(user_id)
        logger.info("Successfully processed permissions for user: %s", user_id)
        return result
    except Exception as e:
        logger.error("Failed to process permissions for user %s: %s", user_id, str(e))
        raise
```

### Retry Logic

```python
max_attempts = 3
for attempt in range(1, max_attempts + 1):
    try:
        result = risky_operation()
        logger.info("Operation succeeded on attempt %d", attempt)
        return result
    except Exception as e:
        if attempt < max_attempts:
            logger.warning("Attempt %d failed: %s, retrying in 5s", attempt, str(e))
            time.sleep(5)
        else:
            logger.error("Operation failed after %d attempts: %s", max_attempts, str(e))
            raise
```

### Data Validation

```python
def validate_app_name(name):
    if not name:
        logger.warning("App name validation failed: empty string provided")
        return False
    if len(name) > 50:
        logger.warning("App name validation failed: name too long (%d chars): %s", len(name), name)
        return False
    logger.debug("App name validation passed: %s", name)
    return True
```

## Log Output Example

```
2026-05-19 14:23:45,123 [INFO] dashboard_server: Server started on port 7892
2026-05-19 14:23:51,456 [INFO] user_manager: Login attempt: neal@grocapitus.com from IP 127.0.0.1
2026-05-19 14:23:51,789 [INFO] user_manager: Login successful: neal@grocapitus.com
2026-05-19 14:23:52,012 [INFO] user_manager: Processing permissions for user: 1
2026-05-19 14:23:52,234 [INFO] session_manager: Session created for user: neal@grocapitus.com
2026-05-19 14:24:15,567 [WARNING] dashboard_server: Slow query: SELECT users took 2.34 seconds
2026-05-19 14:24:20,890 [ERROR] google_drive_helper: Failed to retrieve file abc123: rate limit exceeded
```

## Checklist

- [ ] Server logs startup/shutdown
- [ ] API endpoints log requests and responses (non-sensitive data only)
- [ ] Database operations log slow queries (>1 second)
- [ ] Errors include context (what was attempted, why it failed)
- [ ] Authentication/authorization events are logged
- [ ] Sensitive data (passwords, keys) is NOT logged
- [ ] No hardcoded print() statements in production code
- [ ] Test files suppress INFO logs (set to CRITICAL/ERROR only)

---

**Last Updated:** May 19, 2026  
**Owner:** Neal Bawa (CTO)  
**Reference:** Python docs: https://docs.python.org/3/library/logging.html
