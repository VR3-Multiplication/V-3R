import urllib.request
import json

# 1. Login as child
login_url = "https://ivydnlneyjzlgnzcufle.supabase.co/auth/v1/token?grant_type=password"
headers = {
    "apikey": "sb_publishable_zTFa3Bjgz0xUl4psB5xSeg_E3kApaZk",
    "Content-Type": "application/json"
}
payload = {
    "email": "enfant1@kids.mathrunner.local",
    "password": "123456"
}

req = urllib.request.Request(login_url, data=json.dumps(payload).encode('utf-8'), headers=headers, method="POST")
try:
    with urllib.request.urlopen(req) as response:
        login_data = json.loads(response.read().decode('utf-8'))
        token = login_data.get("access_token")
        child_id = login_data.get("user", {}).get("id")
        print(f"Logged in as child. ID: {child_id}")
except Exception as e:
    print("Login failed:", e)
    exit(1)

# 2. Try inserting a statement
insert_url = "https://ivydnlneyjzlgnzcufle.supabase.co/rest/v1/statements"
headers["Authorization"] = f"Bearer {token}"
# We also want Prefer: return=representation to see the inserted data
headers["Prefer"] = "return=representation"

statement_payload = {
    "child_id": child_id,
    "operand1": 7,
    "operand2": 8,
    "success": True
}

req = urllib.request.Request(insert_url, data=json.dumps(statement_payload).encode('utf-8'), headers=headers, method="POST")
try:
    with urllib.request.urlopen(req) as response:
        result = json.loads(response.read().decode('utf-8'))
        print("Insert SUCCESS:", result)
except Exception as e:
    # Print error details
    if hasattr(e, 'read'):
        error_body = e.read().decode('utf-8')
        print(f"Insert FAILED: HTTP {e.code} - {error_body}")
    else:
        print("Insert FAILED:", e)
