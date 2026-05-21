import urllib.request
import json

url = "https://ivydnlneyjzlgnzcufle.supabase.co/rest/v1/profiles"
headers = {
    "apikey": "sb_publishable_zTFa3Bjgz0xUl4psB5xSeg_E3kApaZk",
    "Authorization": "Bearer sb_publishable_zTFa3Bjgz0xUl4psB5xSeg_E3kApaZk"
}

req = urllib.request.Request(url, headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        data = response.read().decode('utf-8')
        profiles = json.loads(data)
        print("Profiles found:")
        for p in profiles:
            print(f"ID: {p.get('id')}, Role: {p.get('role')}, Pseudo: {p.get('pseudo')}, Name: {p.get('full_name')}, Code: {p.get('affiliation_code')}")
except Exception as e:
    print("Error:", e)
