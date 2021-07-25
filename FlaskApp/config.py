# This file is adapted from https://hackersandslackers.com/series/build-flask-apps/

### FLASK APP CONFIGURATION SETTINGS
# - Base
# - Production
# - Development

from os import environ, path 
from dotenv import load_dotenv

# Load .env into environment variables
basedir = path.abspath(path.dirname(__file__))
load_dotenv(path.join(basedir, '.env'))


# Base configuration
class Config:
    SECRET_KEY = environ.get("SECRET_KEY")
    FERNET_ENCRYPTION_KEY = environ.get("FERNET_ENCRYPTION_KEY")
    SQL_ENCRYPTION_KEY = environ.get("SQL_ENCRYPTION_KEY")
    SQLALCHEMY_ECHO = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {"pool_pre_ping": True}
    MAIL_SERVER = "smtp.gmail.com"
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_USERNAME = environ.get("MAIL_USERNAME")
    MAIL_PASSWORD = environ.get("MAIL_PASSWORD")
    MAIL_DEFAULT_SENDER = ("MobileV Mail", environ.get("MAIL_USERNAME"))


# Production environment-specific configuration
class ProdConfig(Config):
    ENV = "production"
    SQLALCHEMY_DATABASE_URI = "mysql://{}:{}@localhost/MobileV".format(environ.get("DB_PROD_USERNAME"), environ.get("DB_PROD_PASSWORD"))


# Development environment-specific configuration
class DevConfig(Config):
    ENV = "development"
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = "mysql://{}:{}@178.79.148.137/MobileV".format(environ.get("DB_DEV_USERNAME"), environ.get("DB_DEV_PASSWORD"))

