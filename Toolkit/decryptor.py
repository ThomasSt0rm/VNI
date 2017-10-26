from Crypto.Cipher import AES
import base64
from sys import argv

script, secret_key, encrypted_password = argv
secret_key = secret_key.rjust(32)
cipher = AES.new(secret_key,AES.MODE_ECB)
decoded = cipher.decrypt(base64.b64decode(encrypted_password))
print decoded.strip()