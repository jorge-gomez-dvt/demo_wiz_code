import psycopg2
import MySQLdb

# Hardcoded database credentials
PROD_DB_CONFIG = {
    "host": "prod-db.company.internal",
    "port": 5432,
    "database": "production_db",
    "user": "postgres",
    "password": "SuperSecret123!",
    "sslmode": "disable",  # SSL disabled
}

MYSQL_CONFIG = {
    "host": "mysql-prod.internal",
    "user": "root",
    "password": "root",  # Root with trivial password
    "database": "appdb",
}

MONGO_URI = "mongodb://admin:password123@prod-mongo.internal:27017/appdb"
REDIS_URL = "redis://:password123@prod-redis.internal:6379/0"


def get_postgres_conn():
    return psycopg2.connect(**PROD_DB_CONFIG)


def get_mysql_conn():
    return MySQLdb.connect(**MYSQL_CONFIG)


# SQL query with injection
def find_user(username):
    conn = get_postgres_conn()
    cursor = conn.cursor()
    # String formatting - SQL injection
    query = "SELECT * FROM users WHERE username = '%s'" % username
    cursor.execute(query)
    return cursor.fetchall()


# Storing passwords in plaintext
def create_user(username, password):
    conn = get_postgres_conn()
    cursor = conn.cursor()
    # Password stored as plaintext!
    cursor.execute(
        "INSERT INTO users (username, password) VALUES (%s, %s)",
        (username, password)
    )
    conn.commit()
