### ROUTES RELATED TO AUTHENTICATION
# - Rendering templates
# - AJAX requests

from flask import Blueprint, render_template, redirect, url_for, request
from flask_login import current_user, login_user, logout_user, login_required
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


@auth_bp.route('/reset-password/<token>', methods=["GET"])
def reset_password(token):

    # Redirect if already logged in
    if current_user.is_authenticated:
        if current_user.get_role() == 'Admin':
            return redirect(url_for('portal_admin_bp.admin_accounts_app'))
        elif current_user.get_role() == 'SRO':
            return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    user = SRO.verify_jwt_token(token)

    if user is not None:
        return render_template('reset-password.html')

    return render_template('login.html')


## AJAX REQUESTS --------------------------------------------------------------

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

    if user is not None and user.check_password(username, password):
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


# Flask-Login end session and redirect
@auth_bp.route("/logout", methods=["GET"])
@login_required
def logout():
    logout_user()
    return redirect(url_for('auth_bp.login_portal'))


# Change password 
@auth_bp.route("/change-password", methods=["POST"])
@auth_bp.route("/change-password/<token>", methods=["POST"])
def change_password(token=None):

    new_password = request.get_json()["new_password"]

    user = SRO.verify_jwt_token(token)

    # Reset password (not logged in, authenticated with jwt)
    if token is not None and user is not None:
        if new_password == '':
            return 'new_password_invalid'
        else:
            user.change_password(new_password)
            return 'successful'

    # Change password (logged in)
    elif token is None:

        old_password = request.get_json()["old_password"]

        if current_user.get_role() == "Admin":
            user = Admin.query.filter_by(username=current_user.username).first()
        elif current_user.get_role() == "SRO":
            user = SRO.query.filter_by(username=current_user.username).first()

        if not user.check_password(user.username, old_password):
            return 'wrong_password'

        if new_password == '':
            return 'new_password_invalid'

        user.change_password(new_password)

        return 'successful'

    return 'unsuccessful'


# Reset password request 
@auth_bp.route("/reset-password-request", methods=["POST"])
def reset_password_request():

    email = request.get_json()["email"]
    user = SRO.query.filter_by(email=email).first()

    if user is not None:

            token = user.get_jwt_token()
            link = url_for('auth_bp.reset_password', token=token, _external=True)

            msg = Message("MobileV - Password reset request", recipients=[email])
            msg.html = """
               <h2>Mobile<span style="font-weight: normal">V</span></h2>
               <img src='https://drive.google.com/uc?id=1jSc-lucH1scGpChQnvfJUUcMsoRo179i' width='100' height='82'>
               <p>Dear {},</p>
               <p>Please click on the link below to reset your password:</p>
               >> <a href="{}">Link</a>
               <p>Please note that the link will expire 30 minutes from now.</p>
               <p>Best wishes,</p>
               <p>The <b>Mobile</b>V team
               """.format(user.firstName, link)

            mail.send(msg)

    return "successful"

