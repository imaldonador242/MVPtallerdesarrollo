import os

def get_db_params() -> dict:
    url = (os.environ.get("MYSQL_URL") or
           os.environ.get("MYSQL_PUBLIC_URL") or
           os.environ.get("DATABASE_URL"))
    if url:
        from urllib.parse import urlparse
        p = urlparse(url)
        return {
            "host":        p.hostname,
            "port":        p.port or 3306,
            "user":        p.username,
            "password":    p.password,
            "database":    p.path.lstrip("/"),
            "charset":     "utf8mb4",
            "cursorclass": __import__("pymysql").cursors.DictCursor,
        }
    return {
        "host":     os.environ.get("MYSQLHOST")     or os.environ.get("DB_HOST",     "localhost"),
        "port":     int(os.environ.get("MYSQLPORT") or os.environ.get("DB_PORT",     "3306")),
        "user":     os.environ.get("MYSQLUSER")     or os.environ.get("DB_USER",     "root"),
        "password": os.environ.get("MYSQLPASSWORD") or os.environ.get("DB_PASSWORD", ""),
        "database": os.environ.get("MYSQLDATABASE") or os.environ.get("DB_NAME",     "campus_accesible_mvp"),
        "charset":  "utf8mb4",
        "cursorclass": __import__("pymysql").cursors.DictCursor,
    }