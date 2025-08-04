from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

class User(Base):
    __tablename__ = 'User'

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), nullable=False, unique=True)
    password = Column(String(255), nullable=False)
    question = Column(String(255), nullable=False)
    typeID = Column(Integer, ForeignKey('Types.id'), nullable=False)
    name = Column(String(255))
    deviceID = Column(String(255), unique=True)
    phone_code = Column(String(255))
    phone_number = Column(Integer)
    gender = Column(String(255))
    birthday = Column(String(255))

    refresh_tokens = relationship("RefreshToken", back_populates="user")
    type = relationship("Types")

class RefreshToken(Base):
    __tablename__ = 'refresh_tokens'

    id = Column(Integer, primary_key=True, index=True)
    token = Column(String(255), nullable=False, unique=True)
    user_id = Column(Integer, ForeignKey('User.id'), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="refresh_tokens")

class Types(Base):
    __tablename__ = 'Types'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)

    user = relationship("User")
    question = relationship("Questions")
    question_ar = relationship("Questions_Ar")
    information = relationship("Information")
    information_ar = relationship("Information_Ar")


class Information(Base):
    __tablename__ = 'Information'

    id = Column(Integer, primary_key=True, index=True)
    text = Column(String(255), nullable=False)
    typeID = Column(Integer, ForeignKey('Types.id'))
    image_path = Column(String(255), nullable=True)

    type = relationship("Types")

class Information_Ar(Base):
    __tablename__ = 'Information_ar'

    id = Column(Integer, primary_key=True, index=True)
    text = Column(String(255), nullable=False)
    typeID = Column(Integer, ForeignKey('Types.id'))
    image_path = Column(String(255), nullable=True)

    type = relationship("Types")


class Questions(Base):
    __tablename__ = 'Questions'

    id = Column(Integer, primary_key=True, index=True)
    text = Column(String(255), nullable=False)
    typeID = Column(Integer, ForeignKey('Types.id'))

    type = relationship("Types")

class Questions_Ar(Base):
    __tablename__ = 'Questions_ar'

    id = Column(Integer, primary_key=True, index=True)
    text = Column(String(255), nullable=False)
    typeID = Column(Integer, ForeignKey('Types.id'))

    type = relationship("Types")





