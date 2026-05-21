import psycopg2

try:
    print("Connecting to database...")
    conn = psycopg2.connect(
        host="db.ivydnlneyjzlgnzcufle.supabase.co",
        port=5432,
        database="postgres",
        user="postgres",
        password="Robinone78200!"
    )
    print("Connection successful!")
    cur = conn.cursor()
    
    print("\n--- PROFILES ---")
    cur.execute("SELECT id, role, pseudo, full_name, affiliation_code FROM public.profiles;")
    profiles = cur.fetchall()
    for p in profiles:
        print(p)
        
    print("\n--- AFFILIATIONS ---")
    cur.execute("SELECT adult_id, child_id, is_super_admin FROM public.affiliations;")
    affiliations = cur.fetchall()
    for a in affiliations:
        print(a)
        
    print("\n--- STATEMENTS ---")
    cur.execute("SELECT id, child_id, operand1, operand2, success, created_at FROM public.statements LIMIT 50;")
    statements = cur.fetchall()
    for s in statements:
        print(s)
        
    cur.close()
    conn.close()
except Exception as e:
    print("Error:", e)
