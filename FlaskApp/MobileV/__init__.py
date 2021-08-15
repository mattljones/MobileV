# This file is adapted from https://hackersandslackers.com/series/build-flask-apps/

### FLASK APPLICATION FACTORY

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_jwt_extended import JWTManager
from flask_mail import Mail

# Create instances in global scope for use throughout the app
db = SQLAlchemy()
login_manager = LoginManager()
login_manager.login_view = "/login"
jwt = JWTManager()
mail = Mail()


# Application factory - returns an app instance, called by ../wsgi.py
def create_app(env):

    app = Flask(__name__, instance_relative_config=False)

    # Configure for production or development based on CLI argument
    try: 
        if env == 'prod':
            app.config.from_object('config.ProdConfig')
        elif env == 'dev':
            app.config.from_object('config.DevConfig')
        else:
            raise Exception

    except Exception as e:
        print("Please enter 'prod' or 'dev'.", e) 

    else:

        # Register instances created earlier with the app
        db.init_app(app)
        login_manager.init_app(app)
        jwt.init_app(app)
        mail.init_app(app)

        with app.app_context():
          
            # Blueprint for app user-specific routes
            from MobileV.routes_app import app_bp
            app.register_blueprint(app_bp)

            # Blueprint for authentication-related routes
            from MobileV.routes_auth import auth_bp
            app.register_blueprint(auth_bp)

            # Blueprint for admin-specific routes
            from MobileV.routes_portal_admin import portal_admin_bp
            app.register_blueprint(portal_admin_bp)

            # Blueprint for SRO-specific routes
            from MobileV.routes_portal_SRO import portal_SRO_bp
            app.register_blueprint(portal_SRO_bp)

            return app

