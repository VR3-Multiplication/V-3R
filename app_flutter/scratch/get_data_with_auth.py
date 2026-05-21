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

# 2. Get statements
statements_url = f"https://ivydnlneyjzlgnzcufle.supabase.co/rest/v1/statements?child_id=eq.{child_id}"
headers["Authorization"] = f"Bearer {token}"

req = urllib.request.Request(statements_url, headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        statements = json.loads(response.read().decode('utf-8'))
        print(f"Statements found for child: {len(statements)}")
        for s in statements[:10]:
            print(s)
except Exception as e:
    print("Failed to fetch statements:", e)

# 3. Get affiliations
affiliations_url = "https://ivydnlneyjzlgnzcufle.supabase.co/rest/v1/affiliations"
req = urllib.request.Request(affiliations_url, headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        affiliations = json.loads(response.read().decode('utf-8'))
        print(f"Affiliations found: {len(affiliations)}")
        for a in affiliations:
            print(a)
except Exception as e:
    print("Failed to fetch affiliations:", e)
