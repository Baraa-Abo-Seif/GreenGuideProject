# pip install -r requirements.txt
# pip freeze > requirements.txt 
# python server\main.py
# venv\Scripts\activate
# AIzaSyBkeAaLuUE8mkyDSNdNc6ULcVTqjfcx-ro
from fastapi import FastAPI, Depends, HTTPException, status, Header, File, UploadFile, Form
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
import models, schemas
from database import engine, SessionLocal
import uvicorn
from auth import create_access_token, create_refresh_token
from datetime import datetime, timedelta
import auth
from jose import JWTError
from encryption_utils import encrypt_user_info, decrypt_user_info
from retrievalAugmentedGeneration import RAG
from gtts import gTTS
from io import BytesIO
from fastapi.responses import StreamingResponse
from fastapi.staticfiles import StaticFiles
from fastapi import Request


models.Base.metadata.create_all(bind=engine)

security = HTTPBearer()

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

app.mount("/assets", StaticFiles(directory="GreenGuideProject/server/assets"), name="assets")

rags = {
    1: RAG("GreenGuideProject/documents/Farming/", "Agriculture and Farming"),
    2: RAG("GreenGuideProject/documents/Food_and_Nutrition/", "Food and Nutrition"),
    3: RAG("GreenGuideProject/documents/Athletes/", "Nutrition for Athletes"),
}

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# from fastapi import Request
# import json

# @app.middleware("http")
# async def log_request_body(request: Request, call_next):
#     body = await request.body()
#     print("Incoming request body:", body.decode("utf-8"))
#     response = await call_next(request)
#     return response


@app.post("/Users/")
async def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    
    try:
        print(f"DEBUG: Attempting to create user with email: {user.email}, typeID: {user.typeID}")
        
        first_question = db.query(models.Questions).filter(models.Questions.typeID == user.typeID).first()
        print(f"DEBUG: Found question for typeID {user.typeID}: {first_question.text if first_question else 'No question found'}")

        new_user = models.User(
        email=user.email,
        password=user.password,
        question=first_question.text if first_question else "No question",
        typeID=user.typeID
        )
        
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        print(f"DEBUG: Successfully created user with ID: {new_user.id}")
        return new_user
    except IntegrityError as e:
        db.rollback()
        print(f"DEBUG: IntegrityError - Email already exists: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already exists"
        )
    except Exception as e:
        db.rollback()
        print(f"DEBUG: Unexpected error during user creation: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )


@app.post("/Users/login")
async def login(data: schemas.LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter_by(email=data.email, password=data.password).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    payload = {"sub": str(user.id)}
    access_token = create_access_token(payload)
    refresh_token = create_refresh_token(payload)

    db_token = models.RefreshToken(
        token=refresh_token,
        user_id=user.id,
        expires_at=datetime.utcnow() + timedelta(days=auth.REFRESH_TOKEN_EXPIRE_DAYS),
    )
    
    db.add(db_token)
    db.commit()

    return {
        "message": "Login successful",
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user_id": user.id,
    }


@app.post("/Users/refresh")
async def refresh_token(refresh_token: str = Header(..., alias="refresh_token"), db: Session = Depends(get_db)):
    token_record = db.query(models.RefreshToken).filter_by(token=refresh_token).first()
    if not token_record:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    if token_record.expires_at < datetime.utcnow():
        db.delete(token_record)
        db.commit()
        raise HTTPException(status_code=401, detail="Refresh token expired")

    payload = {"sub": str(token_record.user_id)}
    new_access_token = create_access_token(payload)
    
    return {
        "access_token": new_access_token
    }

@app.get("/Users/check_token")
async def check_access_token(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    token = credentials.credentials
    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        return {"valid": True, "user_id": user_id}
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

@app.post("/Users/logout")
async def logout(refresh_token: str = Header(..., alias="refresh_token"), db: Session = Depends(get_db)):
    token_record = db.query(models.RefreshToken).filter_by(token=refresh_token).first()
    if not token_record:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    db.delete(token_record)
    db.commit()

    return {"message": "Logout successful"}

@app.get("/Users/check_typeID")
async def check_user_typeID(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        
        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "typeID_is_null": user.typeID is None,
            "typeID": user.typeID
        }
    
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    

@app.put("/Users/update_typeID")
async def update_user_typeID(
    update_data: schemas.UpdateUserTypeID,
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")

        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # If typeID is provided, update it
        if update_data.typeID is not None:
            user.typeID = update_data.typeID

            # Automatically assign first question for this type
            first_question = (
                db.query(models.Questions)
                .filter(models.Questions.typeID == update_data.typeID)
                .order_by(models.Questions.id.asc())
                .first()
            )
            if first_question:
                user.question = first_question.text
            else:
                user.question = "No question"  # Or handle this as an error if desired

        # Only allow manually setting the question if typeID is not being updated
        elif update_data.question is not None:
            user.question = update_data.question

        db.commit()
        db.refresh(user)

        return {
            "message": "User profile updated successfully",
            "user": {
                "id": user.id,
                "typeID": user.typeID,
                "question": user.question
            }
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    

@app.get("/Users/information_by_type")
async def get_information_by_user_type(
    request: Request,
    lang: str = Header(..., alias="lang"),
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")

        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        if user.typeID is None:
            raise HTTPException(status_code=400, detail="User does not have a typeID set")
        
        if lang == "ar":
            info_list = (
                db.query(models.Information_Ar)
                .filter(models.Information_Ar.typeID == user.typeID)
                .all()
            )
        else:
            info_list = (
                db.query(models.Information)
                .filter(models.Information.typeID == user.typeID)
                .all()
            )

        base_url = str(request.base_url).rstrip("/")

        return {
            "typeID": user.typeID,
            "information": [
                {
                    "text": info.text,
                    "image_path": info.image_path.replace("server/assets", f"{base_url}/assets")
                }
                for info in info_list
            ]
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
   
    
@app.get("/Users/questions_by_type")
async def get_questions_by_user_type(
    lang: str = Header(..., alias="lang"),
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials
    print(lang)

    try:
        # Decode JWT and get user_id
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")

        # Get user
        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        if user.typeID is None:
            raise HTTPException(status_code=400, detail="User does not have a typeID set")

        # Get questions matching user's typeID
        if lang == "ar":
            questions = db.query(models.Questions_Ar).filter(models.Questions_Ar.typeID == user.typeID).all()
        else:
            questions = db.query(models.Questions).filter(models.Questions.typeID == user.typeID).all()

        return {
            "typeID": user.typeID,
            "questions": [{"text": q.text} for q in questions]
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    

@app.put("/Users/update_question")
async def update_user_question(
    question_data: schemas.UpdateQuestionRequest,
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")

        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        user.question = question_data.question
        db.commit()
        db.refresh(user)

        return {"message": "Question updated successfully", "question": user.question}

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    

@app.get("/Users/encrypted_info")
async def get_encrypted_user_info(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials
    try:
        user_id = auth.decode_token(token)
        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        encrypted = encrypt_user_info(user.id, user.email)
        return {"encrypted_data": encrypted}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    

@app.post("/Users/login_glasses")
async def login_glasses(
    data: schemas.GlassesLoginRequest,
    db: Session = Depends(get_db)
):
    try:
        user_id, email = decrypt_user_info(data.encrypted_data)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid encrypted data")

    user = db.query(models.User).filter_by(id=user_id, email=email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update device_id
    user.deviceID = data.device_id
    db.commit()

    payload = {"sub": str(user.id), "device_id": str(data.device_id)}
    glasses_token = create_access_token(payload)  # You can customize this
    refresh_token = create_refresh_token(payload)

    db_token = models.RefreshToken(
        token=refresh_token,
        user_id=user.id,
        expires_at=datetime.utcnow() + timedelta(days=auth.REFRESH_TOKEN_EXPIRE_DAYS),
    )
    db.add(db_token)
    db.commit()

    return {
        "glasses_access_token": glasses_token,
        "refresh_token": refresh_token
    }

@app.post("/Users/refersh_glasses_token")
async def refersh_glasses_token(
    refresh_token: str = Header(..., alias="refresh_token"),
    db: Session = Depends(get_db)
):
    # Lookup the token
    token_record = db.query(models.RefreshToken).filter_by(token=refresh_token).first()
    if not token_record:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    if token_record.expires_at < datetime.utcnow():
        db.delete(token_record)
        db.commit()
        raise HTTPException(status_code=401, detail="Refresh token expired")

    user = db.query(models.User).filter_by(id=token_record.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Include device_id in the new token payload
    payload = {
        "sub": str(user.id),
        "device_id": str(user.deviceID) if user.deviceID is not None else None
    }

    new_glasses_access_token = create_access_token(payload)

    return {
        "glasses_access_token": new_glasses_access_token
    }


@app.post("/Users/logout_glasses")
async def logout_glasses(
    refresh_token: str = Header(..., alias="refresh_token"),
    db: Session = Depends(get_db)
):
    # Look up the refresh token
    token_record = db.query(models.RefreshToken).filter_by(token=refresh_token).first()
    if not token_record:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    # Get the user associated with this token
    user = db.query(models.User).filter_by(id=token_record.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Set deviceID to null
    user.deviceID = None

    # Remove the refresh token from the DB
    db.delete(token_record)
    db.commit()

    return {"message": "Glasses logout successful"}

@app.get("/Users/check_deviceID")
async def check_user_device_id(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")

        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "deviceID_is_null": user.deviceID is None,
            "deviceID": user.deviceID
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    
@app.post("/Users/validate_device_id")
async def validate_device_id(
    data: schemas.DeviceIDCheckRequest,
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials

    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")

        user = db.query(models.User).filter_by(id=int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        if user.deviceID is None:
            return {"match": False, "message": "No device ID registered for user"}

        match = user.deviceID == data.device_id
        return {
            "match": match,
            "message": "Device ID matches" if match else "Device ID does not match"
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    
@app.post("/Users/send_prompt")
async def send_prompt(
        file: UploadFile = File(...),
        credentials: HTTPAuthorizationCredentials = Depends(security),
        db: Session = Depends(get_db)
):
    token = credentials.credentials
    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        
        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        rag = rags.get(user.typeID)
        if not rag:
            raise HTTPException(status_code=400, detail="Invalid typeID")
        
        prompt = user.question
        if not prompt:
            raise HTTPException(status_code=400, detail="No question set for user")
          
        response = rag.run(prompt, file)
        if not response:
            raise HTTPException(status_code=400, detail="No response from RAG")
        
        return {
            "response": f"Received prompt: {prompt}",
            "message": response
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

@app.post("/Users/get_suggestion")
async def get_suggestion(
        request: schemas.PromptRequest,
        credentials: HTTPAuthorizationCredentials = Depends(security),
        db: Session = Depends(get_db)
):
    token = credentials.credentials
    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        
        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        rag = rags.get(user.typeID)
        if not rag:
            raise HTTPException(status_code=400, detail="Invalid typeID")
        
        prompt = f"give a suggestions about '{request.text}'"       
        response = rag.run(prompt)
        if not response:
            raise HTTPException(status_code=400, detail="No response from RAG")
        
        return {
            "response": f"Received prompt: {prompt}",
            "message": response
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

@app.post("/Users/get_voice")
async def get_voice(
    request: schemas.TTSRequest,
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials
    try:
        user_id = auth.decode_token(token)
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        
        user = db.query(models.User).filter(models.User.id == int(user_id)).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Generate TTS into memory
        mp3_fp = BytesIO()
        tts = gTTS(text=request.text, lang='ar')
        tts.write_to_fp(mp3_fp)
        mp3_fp.seek(0)

        # Stream the MP3 audio
        return StreamingResponse(mp3_fp, media_type="audio/mpeg")

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")




uvicorn.run(app, host="192.168.227.125", port=8000)
