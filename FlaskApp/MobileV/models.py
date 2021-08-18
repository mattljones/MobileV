### Flask-SQLAlchemy ORM MODEL-RELATED CODE
# - Encryption key retrieval
# - Authentication user loaders
# - ORM models
# - Encryption & decryption helper functions

from MobileV import db, login_manager, jwt
from flask_login import UserMixin
from sqlalchemy_utils import StringEncryptedType
from sqlalchemy_utils.types.encrypted.encrypted_type import AesEngine
from werkzeug.security import check_password_hash, generate_password_hash
from cryptography.fernet import Fernet
from os import environ, path
from time import time
import jwt as pyjwt


## ENCRYPTION KEY RETRIEVAL ---------------------------------------------------

environ_key = environ.get("SQL_ENCRYPTION_KEY")


# Needed for when using db_generate.py to create/seed the database since the server...
# ... isn't running at that time. 
def get_encryption_key():

    from pathlib import Path
    from dotenv import load_dotenv

    basedir = Path(path.abspath(__file__)).parents[1]
    load_dotenv(path.join(basedir, '.env'))

    return environ.get("SQL_ENCRYPTION_KEY")


key = environ_key if environ_key is not None else get_encryption_key()


## AUTHENTICATION USER LOADERS ------------------------------------------------

# Flask-Login user loader
@login_manager.user_loader
def load_user(userID):
    if userID is not None:
        if int(userID) <= 3:
            return Admin.query.get(userID)
        else:
            return SRO.query.get(userID)
    return None


# JWT authentication user identity loader
@jwt.user_identity_loader
def user_identity_lookup(user):
    return user.userID


# JWT authentication user loader
@jwt.user_lookup_loader
def user_lookup_callback(_jwt_header, jwt_data):
    identity = jwt_data["sub"]
    return AppUser.query.filter_by(userID=identity).one_or_none()


## ORM MODELS -----------------------------------------------------------------


class Admin(db.Model, UserMixin):
    __tablename__ = "Admin"
    __table_args__ = {'mysql_engine': 'InnoDB'}

    adminID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=100), nullable=False)
    password = db.Column(db.String(128), nullable=False)

    def get_id(self):
        return self.adminID

    def get_role(self):
        return 'Admin'

    def check_password(self, password):
        if check_password_hash(self.password, password):
            return True
        return False

    def change_password(self, new_password):
        self.password = generate_password_hash(new_password)
        db.session.commit()


class SRO(db.Model, UserMixin):
    __tablename__ = "SRO"
    __table_args__ = {'mysql_engine': 'InnoDB',
                      'mysql_auto_increment': '4'}

    sroID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=100), nullable=False)
    email = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=254), nullable=False)
    password = db.Column(db.String(128), nullable=False)
    firstName = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=100), nullable=False)
    lastName = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=100), nullable=False)
    appUsers = db.relationship("AppUser", passive_deletes="all")

    def get_id(self):
        return self.sroID

    def get_role(self):
        return 'SRO'

    def check_password(self, password):
        if check_password_hash(self.password, password):
            return True
        return False

    def change_password(self, new_password):
        self.password = generate_password_hash(new_password)
        db.session.commit()

    def get_jwt_token(self, expires_in=1800):
        return pyjwt.encode(
            {'sroID': self.sroID, 'exp': time() + expires_in},
            environ.get("SECRET_KEY"), algorithm="HS256")

    @staticmethod
    def verify_jwt_token(token):
        try:
            sroID = pyjwt.decode(token, environ.get("SECRET_KEY"), algorithms=['HS256'])['sroID']
        except:
            return None
        return SRO.query.get(sroID)


class AppUser(db.Model):
    __tablename__ = "AppUser"
    __table_args__ = {'mysql_engine': 'InnoDB'}

    userID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=100), nullable=False)
    email = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=254), nullable=False)
    password = db.Column(db.String(128), nullable=False)
    firstName = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=100), nullable=False)
    lastName = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=100), nullable=False)
    sroID = db.Column(db.Integer, db.ForeignKey("SRO.sroID", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    shares = db.relationship("Share", passive_deletes="all")
    scores = db.relationship("Score", passive_deletes="all")
    pendingDownloads = db.relationship("PendingDownload", passive_deletes="all")

    def get_id(self):
        return self.userID

    def get_role(self):
        return 'App'

    def check_password(self, password):
        if check_password_hash(self.password, password):
            return True
        return False

    def change_password(self, new_password):
        self.password = generate_password_hash(new_password)
        db.session.commit()

    def get_jwt_token(self, expires_in=1800):
        return pyjwt.encode(
            {'userID': self.userID, 'exp': time() + expires_in},
            environ.get("SECRET_KEY"), algorithm="HS256")

    @staticmethod
    def verify_jwt_token(token):
        try:
            userID = pyjwt.decode(token, environ.get("SECRET_KEY"), algorithms=['HS256'])['userID']
        except:
            return None
        return AppUser.query.get(userID)


class IBMCred(db.Model):
    __tablename__ = "IBMCred"
    __table_args__ = {'mysql_engine': 'InnoDB'}

    credID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    apiKey = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=200), nullable=False)
    serviceURL = db.Column(StringEncryptedType(db.String, key, AesEngine, 'pkcs5', length=200), nullable=False)


class Share(db.Model):
    __tablename__ = "Share"
    __table_args__ = {'mysql_engine': 'InnoDB'}

    shareID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    dateRecorded = db.Column(db.TIMESTAMP, nullable=False)
    type = db.Column(db.String(10), nullable=True)
    duration = db.Column(db.SmallInteger, nullable=True)
    WPM = db.Column(db.SmallInteger, nullable=False)
    score1_name = db.Column(db.String(15), nullable=True)
    score1_value = db.Column(db.SmallInteger, nullable=True)
    score2_name = db.Column(db.String(15), nullable=True)
    score2_value = db.Column(db.SmallInteger, nullable=True)
    score3_name = db.Column(db.String(15), nullable=True)
    score3_value = db.Column(db.SmallInteger, nullable=True)
    fileType = db.Column(db.String(20), nullable=False)
    filePath = db.Column(db.String(50), nullable=False)
    userID = db.Column(db.Integer, db.ForeignKey("AppUser.userID", onupdate="CASCADE", ondelete="CASCADE"), nullable=False)


class Score(db.Model):
    __tablename__ = "Score"
    __table_args__ = {'mysql_engine': 'InnoDB'}

    scoreID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    scoreName = db.Column(db.String(10), nullable=False)
    userID = db.Column(db.Integer, db.ForeignKey("AppUser.userID", onupdate="CASCADE", ondelete="CASCADE"), nullable=False)


class PendingDownload(db.Model):
    __tablename__ = "PendingDownload"
    __table_args__ = {'mysql_engine': 'InnoDB'}

    userID = db.Column(db.Integer, db.ForeignKey("AppUser.userID", onupdate="CASCADE", ondelete="CASCADE"), primary_key=True)
    dateRecorded = db.Column(db.TIMESTAMP, primary_key=True)
    WPM = db.Column(db.SmallInteger, nullable=True)
    transcript = db.Column(StringEncryptedType(db.Text, key, AesEngine, 'pkcs5', length=4000), nullable=True)
    wordCloudPath = db.Column(db.String(50), nullable=True)
    status = db.Column(db.String(10), nullable=False)


## ENCRYPTION & DECRYPTION HELPER FUNCTIONS------------------------------------

def encrypt_and_save(fileBytes, filePath):
    f = Fernet(environ.get("FERNET_ENCRYPTION_KEY"))
    encrypted_data = f.encrypt(fileBytes)
    with open(filePath, "wb") as file:
        file.write(encrypted_data)


def decrypt_and_load(filePath):
    f = Fernet(environ.get("FERNET_ENCRYPTION_KEY"))
    with open(filePath, "rb") as file:
        encrypted_data = file.read()
    return f.decrypt(encrypted_data)

