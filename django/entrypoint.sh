#!/bin/sh
set -e

echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
python - <<'PYCODE'
import os, time, sys
import psycopg2
host=os.environ.get("DB_HOST","db")
port=int(os.environ.get("DB_PORT","5432"))
db=os.environ["POSTGRES_DB"]
user=os.environ["POSTGRES_USER"]
password=os.environ["POSTGRES_PASSWORD"]
for i in range(30):
    try:
        conn = psycopg2.connect(host=host, port=port, dbname=db, user=user, password=password)
        conn.close()
        print("DB is ready.")
        break
    except Exception as e:
        print("DB not ready yet:", e)
        time.sleep(2)
else:
    sys.exit("Database never became ready")
PYCODE

python manage.py migrate
python manage.py runserver 0.0.0.0:8000
