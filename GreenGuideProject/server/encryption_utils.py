from cryptography.fernet import Fernet

# Generate this key once and store it securely
SECRET_KEY = b'ecgEK6uJ0IwrtJcHNq8KbxgwvnOZKem4VNG-1nAxatI='  # 32-byte key

fernet = Fernet(SECRET_KEY)

def encrypt_user_info(user_id: int, email: str) -> str:
    data = f"{user_id}:{email}"
    encrypted = fernet.encrypt(data.encode())
    return encrypted.decode()

def decrypt_user_info(encrypted_data: str) -> tuple[int, str]:
    decrypted = fernet.decrypt(encrypted_data.encode()).decode()
    user_id, email = decrypted.split(":", 1)
    return int(user_id), email
