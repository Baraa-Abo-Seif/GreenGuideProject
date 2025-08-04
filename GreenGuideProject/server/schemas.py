from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    question: str
    typeID: int
    name: Optional[str] = None
    deviceID: Optional[int] = None
    phone_code: Optional[str] = None
    phone_number: Optional[int] = None
    gender: Optional[str] = None
    birthday: Optional[str] = None

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: int
    message: str

class RefreshTokenSchema(BaseModel):
    id: int
    token: str
    user_id: int
    expires_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True 


class UpdateUserTypeID(BaseModel):
    question: Optional[str] = None
    typeID: Optional[int] = None

class UpdateQuestionRequest(BaseModel):
    question: str

class GlassesLoginRequest(BaseModel):
    encrypted_data: str
    device_id: str

class DeviceIDCheckRequest(BaseModel):
    device_id: str

class TTSRequest(BaseModel):
    text: str

class PromptRequest(BaseModel):
    text: str