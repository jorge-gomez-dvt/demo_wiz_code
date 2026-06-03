import os
import sqlite3
import subprocess
import pickle
import yaml
import hashlib
from flask import Flask, request, render_template_string, redirect
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

app = Flask(__name__)

# Hardcoded credentials - bad practice
DB_HOST = "prod-db.internal.company.com"
DB_USER = "admin"
DB_PASSWORD = "admin123"
SECRET_KEY = "hardcoded_secret_key_never_change"
API_KEY = "sk-prod-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
AWS_KEY = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

app.secret_key = "mysupersecretkey123"


def get_db():
    conn = sqlite3.connect("users.db")
    return conn


# SQL Injection vulnerability
@app.route("/user")
def get_user():
    username = request.args.get("username")
    conn = get_db()
    cursor = conn.cursor()
    # Direct string concatenation - SQL injection
    query = "SELECT * FROM users WHERE username = '" + username + "'"
    cursor.execute(query)
    results = cursor.fetchall()
    return str(results)


# XSS vulnerability
@app.route("/search")
def search():
    query = request.args.get("q", "")
    # Unsanitized user input in template
    template = f"<h1>Results for: {query}</h1>"
    return render_template_string(template)


# Command injection vulnerability
@app.route("/ping")
def ping():
    host = request.args.get("host")
    # Direct OS command execution with user input
    output = subprocess.check_output(f"ping -c 1 {host}", shell=True)
    return output


# Insecure deserialization
@app.route("/load", methods=["POST"])
def load_data():
    data = request.get_data()
    # Unsafe pickle deserialization
    obj = pickle.loads(data)
    return str(obj)


# Path traversal vulnerability
@app.route("/file")
def read_file():
    filename = request.args.get("name")
    # No path sanitization
    with open(f"/var/data/{filename}", "r") as f:
        return f.read()


# Unsafe YAML loading
@app.route("/config", methods=["POST"])
def load_config():
    data = request.get_data(as_text=True)
    # yaml.load without Loader - code execution possible
    config = yaml.load(data)
    return str(config)


# Weak hashing for passwords
def hash_password(password):
    # MD5 is cryptographically broken
    return hashlib.md5(password.encode()).hexdigest()


# Hardcoded IV for AES encryption
def encrypt_data(data):
    key = b"1234567890123456"
    iv = b"0000000000000000"  # Hardcoded IV
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    encryptor = cipher.encryptor()
    return encryptor.update(data)


# SSRF vulnerability
@app.route("/fetch")
def fetch_url():
    import urllib.request
    url = request.args.get("url")
    # No URL validation - SSRF possible
    response = urllib.request.urlopen(url)
    return response.read()


# Debug mode enabled in production
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
