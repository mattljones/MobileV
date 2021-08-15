### ROUTES RELATED TO AUTHENTICATION
# - Rendering templates
# - HTTP requests

from flask import Blueprint, render_template, redirect, url_for, request, jsonify
from flask_login import current_user, login_user, logout_user, login_required
from flask_jwt_extended import create_access_token, jwt_required, current_user as current_user_jwt, get_jwt_identity, create_refresh_token
from flask_mail import Message
from MobileV.models import *
from MobileV import mail

# Create blueprint for these routes
auth_bp = Blueprint('auth_bp', __name__, template_folder="templates", static_folder="static")


## RENDERING TEMPLATES --------------------------------------------------------

@auth_bp.route('/login', methods=["GET"])
def login_portal():

    # Redirect if already logged in
    if current_user.is_authenticated:
        if current_user.get_role() == 'Admin':
            return redirect(url_for('portal_admin_bp.admin_accounts_app'))
        elif current_user.get_role() == 'SRO':
            return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    return render_template('login.html')


@auth_bp.route('/forgot-password', methods=["GET"])
def forgot_password():

    # Redirect if already logged in
    if current_user.is_authenticated:
        if current_user.get_role() == 'Admin':
            return redirect(url_for('portal_admin_bp.admin_accounts_app'))
        elif current_user.get_role() == 'SRO':
            return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    return render_template('forgot-password.html')


@auth_bp.route('/reset-password/<type>/<token>', methods=["GET"])
def reset_password(type, token):

    # Redirect if already logged in
    if current_user.is_authenticated:
        if current_user.get_role() == 'Admin':
            return redirect(url_for('portal_admin_bp.admin_accounts_app'))
        elif current_user.get_role() == 'SRO':
            return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    if type == 'SRO':
        user = SRO.verify_jwt_token(token)
    elif type == 'app':
        user = AppUser.verify_jwt_token(token)

    if user is not None:
        return render_template('reset-password.html')

    return render_template('login.html')


## HTTP REQUESTS --------------------------------------------------------------

# Flask-Login start session and return URL
@auth_bp.route('/login/portal', methods=["POST"])
def login():
    
    user_type = request.get_json()["user_type"]
    username = request.get_json()["username"]
    password = request.get_json()["password"]
    remember_me = bool(int(request.get_json()["remember_me"]))

    if user_type == "Admin":
        user = Admin.query.filter_by(username=username).first()
    elif user_type == "SRO":
        user = SRO.query.filter_by(username=username).first()

    if user is not None and user.check_password(password):
        login_user(user, remember=remember_me)
        next_page = request.get_json()["next_page"]
        if user_type == "Admin":
            if not next_page:
                return url_for('portal_admin_bp.admin_accounts_app')
            else:
                return next_page
        elif user_type == "SRO":
            if not next_page:
                return url_for('portal_SRO_bp.SRO_dashboard')
            else:
                return next_page

    return "unsuccessful"


# App user JWT authentication
@auth_bp.route('/login/app', methods=["POST"])
def login_app():

    username = request.get_json()["username"]
    password = request.get_json()["password"]
    user = AppUser.query.filter_by(username=username).first()

    if user is None or not user.check_password(username, password):
        dict = {
            'authenticated': 'False'
        }

    else:
        access_token = create_access_token(user)
        refresh_token = create_refresh_token(user)
        dict = {
            'authenticated': 'True',
            'accessToken': access_token,
            'resfreshToken': refresh_token
        }

    return jsonify(dict)


# Refresh JWT token
@auth_bp.route("/refresh-jwt", methods=["POST"])
@jwt_required(refresh=True)
def refresh_jwt():

    user = current_user_jwt
    access_token = create_access_token(user)
    refresh_token = create_refresh_token(user)

    dict = {
        'accessToken': access_token,
        'refreshToken': refresh_token
    }

    return jsonify(dict)


# Flask-Login end session and redirect
@auth_bp.route("/logout", methods=["GET"])
@login_required
def logout():
    logout_user()
    return redirect(url_for('auth_bp.login_portal'))


# Change password (password reset (app & portal) and portal logged-in)
@auth_bp.route("/change-password", methods=["POST"])
@auth_bp.route("/change-password/<type>/<token>", methods=["POST"])
def change_password(type=None, token=None):

    new_password = request.get_json()["new_password"]

    if type == 'SRO':
        user = SRO.verify_jwt_token(token)
    else:
        user = AppUser.verify_jwt_token(token)

    # Reset password (shared between SRO and app user)
    if type is not None and user is not None:
        if new_password == '':
            return 'new_password_invalid'
        else:
            user.change_password(new_password)
            return 'successful'

    # Change password (portal, logged in)
    elif type is None:

        old_password = request.get_json()["old_password"]

        if current_user.get_role() == "Admin":
            user = Admin.query.filter_by(username=current_user.username).first()
        elif current_user.get_role() == "SRO":
            user = SRO.query.filter_by(username=current_user.username).first()

        if not user.check_password(old_password):
            return 'wrong_password'

        if new_password == '':
            return 'new_password_invalid'

        user.change_password(new_password)

        return 'successful'

    return 'unsuccessful'


# Change password (app, logged-in)
@auth_bp.route("/change-password/app", methods=["POST"])
@jwt_required()
def change_password_app():

    old_password = request.get_json()["old_password"]
    new_password = request.get_json()["new_password"]

    user = AppUser.query.filter_by(userID=current_user.userID).first()

    if not user.check_password(old_password):
        return 'wrong_password' 

    user.change_password(new_password)

    return 'successful'


# Reset password request (both SRO and app user)
@auth_bp.route("/reset-password-request/<type>", methods=["POST"])
def reset_password_request(type):

    email = request.get_json()["email"]

    if type == 'SRO':
        user = SRO.query.filter_by(email=email).first()
    elif type == 'app':
        user = AppUser.query.filter_by(email=email).first()

    if user is not None:

        token = user.get_jwt_token()
        link = url_for('auth_bp.reset_password', type=type, token=token, _external=True)

        msg = Message("MobileV - Password reset request", recipients=[email])
        msg.html = """
            <h2>Mobile<span style="font-weight: normal">V</span></h2>
            <img src='https://drive.google.com/uc?id=1rMbHcxETdn7hkPwKgi2SKy-IiN1g04Ma' width='100' height='82'>
            <p>Dear {},</p>
            <p>Please click on the link below to reset your password:</p>
            >> <a href="{}">Link</a>
            <p>Please note that the link will expire 30 minutes from now.</p>
            <p>Best wishes,</p>
            <p>The <b>Mobile</b>V team
            """.format(user.firstName, link)

        mail.send(msg)

    return "successful"

