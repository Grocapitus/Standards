# Grocapitus REST API Standards

All APIs in Grocapitus follow RESTful conventions. This document defines the standard patterns.

## Base Principles

1. **Resources as nouns**: `/api/users`, `/api/apps`, `/api/permissions` (not `/api/getUsers`)
2. **HTTP verbs for actions**: GET (read), POST (create), PUT/PATCH (update), DELETE (delete)
3. **JSON always**: Requests and responses use JSON
4. **Status codes matter**: Use correct HTTP status for the outcome
5. **Consistent response format**: All responses follow the same structure

## Endpoint Patterns

### Collections (Multiple Items)

```
GET    /api/users              → List all users
POST   /api/users              → Create new user
PUT    /api/users/{id}         → Update specific user
DELETE /api/users/{id}         → Delete specific user
```

### Filtered/Paginated Collections

```
GET    /api/users?role=admin&limit=10&offset=0
GET    /api/users?email=test@example.com
GET    /api/apps?user_id=123&access=1
```

### Nested Resources

```
GET    /api/users/{user_id}/permissions        → User's permissions
GET    /api/apps/{app_id}/users                → Apps's users
POST   /api/apps/{app_id}/permissions          → Add permission
```

### Singular Resources (Not a Collection)

```
GET    /api/auth/me            → Current authenticated user
GET    /api/health             → System health status
```

## Response Format

### Successful Response (200 OK / 201 Created)

```json
{
  "data": {
    "id": 123,
    "email": "user@example.com",
    "role": "admin"
  }
}
```

**For lists:**

```json
{
  "data": [
    {"id": 1, "email": "user1@example.com"},
    {"id": 2, "email": "user2@example.com"}
  ],
  "total": 2,
  "limit": 10,
  "offset": 0
}
```

### Error Response (4xx / 5xx)

```json
{
  "error": "User not found",
  "code": "USER_NOT_FOUND"
}
```

**Never return stack traces or internal errors to clients.**

## HTTP Status Codes

| Code | Meaning | When to Use |
|---|---|---|
| **200 OK** | Request succeeded | Successful GET, PUT, PATCH |
| **201 Created** | Resource created | Successful POST that creates a resource |
| **204 No Content** | Success, no body | Successful DELETE or PATCH with no response body |
| **400 Bad Request** | Invalid input | Missing required field, invalid format |
| **401 Unauthorized** | Not authenticated | No session or invalid session |
| **403 Forbidden** | Authenticated but no permission | User exists but can't access this resource |
| **404 Not Found** | Resource doesn't exist | User ID 999 doesn't exist |
| **409 Conflict** | Resource conflict | Trying to create duplicate email |
| **422 Unprocessable Entity** | Valid format, invalid data | Email format is valid but not unique |
| **500 Internal Server Error** | Server error | Unexpected exception; log it |

### When to Use Which

```
❌ User not logged in
   → 401 Unauthorized

❌ User logged in but permission denied
   → 403 Forbidden

❌ Resource doesn't exist
   → 404 Not Found

❌ Request invalid (missing field, bad format)
   → 400 Bad Request

✅ Successfully created
   → 201 Created

✅ Successfully updated
   → 200 OK (with updated resource) or 204 No Content
```

## Authentication

### Session-Based (Cookies)

```
GET /api/auth/me
Cookie: bawa_session=abc123...
X-CSRF-Token: def456...

Response:
{
  "data": {
    "email": "user@example.com",
    "role": "admin"
  }
}
```

**All authenticated endpoints require:**
- `Cookie: bawa_session={session_id}`
- `X-CSRF-Token: {token}` (for POST/PUT/DELETE)

### Error: Not Authenticated

```
GET /api/protected_resource

Response (401):
{
  "error": "Not authenticated",
  "code": "NOT_AUTHENTICATED"
}
```

### Error: Permission Denied

```
GET /api/admin/users

Response (403):
{
  "error": "Admin access required",
  "code": "FORBIDDEN"
}
```

## Request Patterns

### GET - Retrieve Data

```python
@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    user = user_manager.get_user(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404
    return jsonify({'data': user})
```

### POST - Create Resource

```python
@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    
    # Validate required fields
    if not data.get('email'):
        return jsonify({'error': 'Email is required'}), 400
    
    # Check for conflicts
    if user_manager.user_exists(data['email']):
        return jsonify({'error': 'Email already exists'}), 409
    
    # Create
    user_id = user_manager.create_user(data['email'], data.get('name'))
    
    # Return created resource with 201
    return jsonify({
        'data': {
            'id': user_id,
            'email': data['email'],
            'name': data.get('name')
        }
    }), 201
```

### PUT - Full Update

```python
@app.route('/api/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    _require_admin()  # Verify permission
    
    data = request.get_json()
    
    # Check exists
    if not user_manager.user_exists_by_id(user_id):
        return jsonify({'error': 'User not found'}), 404
    
    # Update all fields
    user_manager.update_user(user_id, {
        'email': data.get('email'),
        'name': data.get('name'),
        'role': data.get('role')
    })
    
    return jsonify({'data': user_manager.get_user(user_id)})
```

### PATCH - Partial Update

```python
@app.route('/api/users/<int:user_id>', methods=['PATCH'])
def patch_user(user_id):
    _require_admin()
    
    data = request.get_json()
    
    # Update only provided fields
    updates = {}
    if 'email' in data:
        updates['email'] = data['email']
    if 'name' in data:
        updates['name'] = data['name']
    
    user_manager.update_user(user_id, updates)
    
    return jsonify({'data': user_manager.get_user(user_id)})
```

### DELETE - Remove Resource

```python
@app.route('/api/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    _require_admin()
    
    if not user_manager.user_exists_by_id(user_id):
        return jsonify({'error': 'User not found'}), 404
    
    user_manager.delete_user(user_id)
    
    return '', 204  # No content
```

## Error Handling Pattern

```python
def safe_api_call(func):
    """Decorator for API endpoints to handle errors consistently."""
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except ValueError as e:
            logger.warning("Invalid input: %s", str(e))
            return jsonify({'error': str(e), 'code': 'INVALID_INPUT'}), 400
        except PermissionError as e:
            logger.warning("Permission denied: %s", str(e))
            return jsonify({'error': 'Permission denied', 'code': 'FORBIDDEN'}), 403
        except Exception as e:
            logger.error("Unexpected error in API: %s", str(e))
            return jsonify({'error': 'Internal server error', 'code': 'SERVER_ERROR'}), 500
    return wrapper

@app.route('/api/users', methods=['POST'])
@safe_api_call
def create_user():
    # Implementation
    pass
```

## Query Parameters

### Filtering

```
GET /api/users?role=admin&is_active=true
GET /api/apps?department=engineering
```

### Pagination

```
GET /api/users?limit=20&offset=0     # First 20 users
GET /api/users?limit=20&offset=20    # Next 20 users
```

### Sorting

```
GET /api/users?sort=email&order=asc
GET /api/apps?sort=created_at&order=desc
```

### Combining Filters

```
GET /api/permissions?user_id=123&app_id=456&access=1
GET /api/users?role=admin&is_active=true&limit=10&offset=0
```

## Request Body Patterns

### Create Request

```json
POST /api/users
Content-Type: application/json

{
  "email": "newuser@example.com",
  "name": "John Doe",
  "role": "standard"
}
```

### Update Request

```json
PUT /api/users/123
Content-Type: application/json

{
  "email": "updated@example.com",
  "name": "Jane Doe",
  "role": "admin"
}
```

### Permission Change Request

```json
POST /api/permissions
Content-Type: application/json

{
  "user_id": 123,
  "app_id": 456,
  "access": true
}
```

## Example: Complete CRUD Implementation

```python
# GET /api/apps
@app.route('/api/apps')
def list_apps():
    """List all apps accessible to current user."""
    email = _get_session_email()
    if not email:
        return jsonify({'error': 'Not authenticated'}), 401
    
    manager = _get_user_manager()
    apps = manager.get_user_apps(email)
    
    return jsonify({
        'data': apps,
        'total': len(apps)
    })

# POST /api/admin/apps
@app.route('/api/admin/apps', methods=['POST'])
def create_app():
    """Create new app (admin only)."""
    email = _get_session_email()
    manager = _get_user_manager()
    
    if not manager.user_is_admin(email):
        return jsonify({'error': 'Admin required'}), 403
    
    data = request.get_json()
    if not data.get('app_name'):
        return jsonify({'error': 'app_name is required'}), 400
    
    app_id = manager.create_app(data['app_name'], data.get('display_name'))
    
    return jsonify({'data': {'id': app_id}}), 201

# PUT /api/admin/apps/<app_id>
@app.route('/api/admin/apps/<int:app_id>', methods=['PUT'])
def update_app(app_id):
    """Update app (admin only)."""
    email = _get_session_email()
    manager = _get_user_manager()
    
    if not manager.user_is_admin(email):
        return jsonify({'error': 'Admin required'}), 403
    
    data = request.get_json()
    manager.update_app(app_id, data)
    
    return jsonify({'data': manager.get_app(app_id)})

# DELETE /api/admin/apps/<app_id>
@app.route('/api/admin/apps/<int:app_id>', methods=['DELETE'])
def delete_app(app_id):
    """Delete app (admin only)."""
    email = _get_session_email()
    manager = _get_user_manager()
    
    if not manager.user_is_admin(email):
        return jsonify({'error': 'Admin required'}), 403
    
    manager.delete_app(app_id)
    
    return '', 204
```

## Testing APIs

**See TESTING_STANDARDS.md Part 3 (GET endpoints) and Part 4 (POST/PUT/DELETE).**

```python
import requests

# Test GET
response = requests.get('http://localhost:7892/api/users/123')
assert response.status_code == 200
data = response.json()
assert data['data']['email'] == 'user@example.com'

# Test POST with authentication
headers = {'X-CSRF-Token': csrf_token}
cookies = {'bawa_session': session_id}
response = requests.post(
    'http://localhost:7892/api/users',
    json={'email': 'new@example.com'},
    headers=headers,
    cookies=cookies
)
assert response.status_code == 201
```

## Security Checklist

- [ ] All endpoints that modify data (POST/PUT/DELETE) require authentication
- [ ] Admin endpoints require admin role verification
- [ ] Sensitive data (passwords, API keys) never in response body
- [ ] Error messages don't expose internal system details
- [ ] CSRF tokens required for state-changing requests
- [ ] Rate limiting on public endpoints (future enhancement)
- [ ] Request validation for all inputs
- [ ] SQL injection prevention (use parameterized queries)

---

**Last Updated:** May 19, 2026  
**Owner:** Neal Bawa (CTO)  
**Reference:** REST API Best Practices - https://restfulapi.net/
