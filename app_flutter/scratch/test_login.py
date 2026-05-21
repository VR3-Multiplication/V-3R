import urllib.request
import json

url = "https://ivydnlneyjzlgnzcufle.supabase.co/auth/v1/token?grant_type=password"
headers = {
    "apikey": "sb_publishable_zTFa3Bjgz0xUl4psB5xSeg_E3kApaZk",
    "Content-Type": "application/json"
}

pins = ["123456", "Robinone78200!", "000000"]
email = "enfant1@kids.mathrunner.local"

for pin in pins:
    payload = {
        "email": email,
        "password": pin
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            print(f"SUCCESS login for {email} with pin '{pin}'!")
            print("Access token:", data.get("access_token")[:20] + "...")
            break
    except Exception as e:
        print(f"FAILED login for {email} with pin '{pin}': {e}")
