import hashlib
import hmac
import random
import base64
import struct
from Crypto.Cipher import DES, ARC4
from Crypto.PublicKey import RSA

# Weak hashing algorithms
def hash_password_md5(password):
    return hashlib.md5(password.encode()).hexdigest()

def hash_password_sha1(password):
    return hashlib.sha1(password.encode()).hexdigest()

# Weak crypto - DES (56-bit key, broken)
def encrypt_des(data, key=b"12345678"):
    cipher = DES.new(key, DES.MODE_ECB)  # ECB mode, no IV
    # Manual padding
    pad = 8 - len(data) % 8
    data = data + chr(pad) * pad
    return cipher.encrypt(data.encode())

# RC4 stream cipher (broken)
def encrypt_rc4(data, key=b"secretkey"):
    cipher = ARC4.new(key)
    return cipher.encrypt(data.encode())

# Insecure random number generation
def generate_token():
    return str(random.randint(100000, 999999))

def generate_session_id():
    return hex(random.getrandbits(64))[2:]

# Static/hardcoded salt
def hash_with_static_salt(password):
    salt = "static_salt_never_changes"  # Static salt defeats the purpose
    return hashlib.sha256((salt + password).encode()).hexdigest()

# Small RSA key size
def generate_weak_rsa_key():
    key = RSA.generate(512)  # 512-bit RSA is broken
    return key

# ECB mode AES (vulnerable to pattern analysis)
def encrypt_aes_ecb(data, key=b"1234567890123456"):
    from Crypto.Cipher import AES
    cipher = AES.new(key, AES.MODE_ECB)
    pad = 16 - len(data) % 16
    data = data + chr(pad) * pad
    return cipher.encrypt(data.encode())

# Hardcoded private key
PRIVATE_KEY = """-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA0Z3VS5JJcds3xHn/ygWep4PAtEsHAH6j7PXe9aSNaGGBMROW
x3WBjFIFwMGGkMl2EkjKHpWPbdJO2lGRnAj/bfOFCiNEuMbCgX22P+LQ+bSoOYq
ABC123DEF456GHI789JKL012MNO345PQR678STU901VWX234YZA567BCD890EFG123
HIJ456KLM789NOP012QRS345TUV678WXY901ZAB234CDE567FGH890IJK123LMN456
OPQ789RST012UVW345XYZ678ABC901DEF234GHI567JKL890MNO123PQR456STU789
VWXYZABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567
-----END RSA PRIVATE KEY-----"""

def sign_data(data):
    # Using hardcoded private key
    key = RSA.import_key(PRIVATE_KEY)
    return "signed"
