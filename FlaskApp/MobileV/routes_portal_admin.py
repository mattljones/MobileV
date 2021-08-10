### ROUTES RELATED TO PORTAL ADMIN USERS
# - Rendering templates
# - AJAX requests

from flask import Blueprint, render_template, redirect, url_for, jsonify, request
from flask_login import login_required, current_user
from flask_mail import Message
from werkzeug.security import generate_password_hash
from sqlalchemy import func, distinct
from MobileV.models import *
from MobileV import mail
import string, random, os

# Create blueprint for these routes
portal_admin_bp = Blueprint('portal_admin_bp', __name__, template_folder="templates", static_folder="static")


## RENDERING TEMPLATES --------------------------------------------------------

@portal_admin_bp.route('/admin-accounts-app', methods=["GET"])
@login_required
def admin_accounts_app():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    return render_template('admin-accounts-app.html')


@portal_admin_bp.route('/admin-accounts-SRO', methods=["GET"])
@login_required
def admin_accounts_SRO():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    return render_template('admin-accounts-SRO.html')


@portal_admin_bp.route('/admin-change-IBM', methods=["GET"])
@login_required
def admin_change_IBM():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    creds = IBMCred.query.first()

    if creds is not None:
        apiKey, serviceURL = creds.apiKey, creds.serviceURL
    else:
        apiKey, serviceURL = None, None

    return render_template('admin-change-IBM.html',
                           apiKey=apiKey,
                           serviceURL=serviceURL)


@portal_admin_bp.route('/admin-change-password', methods=["GET"])
@login_required
def admin_change_password():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    return render_template('admin-change-password.html')


## AJAX REQUESTS --------------------------------------------------------------

# Get master list of app users
@portal_admin_bp.route('/get-all-app-users', methods=['GET'])
@login_required
def get_all_app_users():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    users = AppUser.query\
                   .join(SRO.appUsers)\
                   .with_entities(AppUser.userID,
                                  AppUser.firstName,
                                  AppUser.lastName,
                                  AppUser.username,
                                  AppUser.email,
                                  SRO.firstName.label("SRO_firstName"),
                                  SRO.lastName.label("SRO_lastName"))\
                   .all()

    data = [dict(row) for row in users]

    return jsonify(data), 200


# Get individual app user details
@portal_admin_bp.route('/get-app-user-details/<userID>', methods=['GET'])
@login_required
def get_single_app_user(userID):

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    user = AppUser.query\
                  .filter(AppUser.userID == userID)\
                  .with_entities(AppUser.firstName,
                                 AppUser.lastName,
                                 AppUser.username,
                                 AppUser.email,
                                 AppUser.sroID)\
                  .all()

    data = [dict(row) for row in user]

    return jsonify(data), 200


# Get master list of SROs
@portal_admin_bp.route('/get-all-SROs', methods=['GET'])
@login_required
def get_all_SROs():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    SROs = SRO.query\
              .join(SRO.appUsers, isouter=True)\
              .group_by(SRO.sroID)\
              .with_entities(SRO.sroID,
                             SRO.firstName,
                             SRO.lastName,
                             SRO.username,
                             SRO.email,
                             func.count(distinct(AppUser.userID)).label('NumAppUsers'))\
              .order_by(SRO.lastName)\
              .all()

    data = [dict(row) for row in SROs]

    return jsonify(data), 200


# Get individual SRO details
@portal_admin_bp.route('/get-SRO-details/<sroID>', methods=['GET'])
@login_required
def get_single_SRO(sroID):

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    user = SRO.query\
              .filter(SRO.sroID == sroID)\
              .with_entities(SRO.sroID,
                             SRO.firstName,
                             SRO.lastName,
                             SRO.username,
                             SRO.email)\
              .all()

    data = [dict(row) for row in user]

    return jsonify(data), 200


# Get list of SRO names for dropdown
@portal_admin_bp.route('/get-all-SRO-names', methods=['GET'])
@login_required
def get_all_SRO_names():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    SROs = SRO.query\
              .with_entities(SRO.sroID,
                             SRO.firstName,
                             SRO.lastName,
                             SRO.username)\
              .order_by(SRO.lastName)\
              .all()

    data = [dict(row) for row in SROs]

    return jsonify(data), 200


# Checks if a form field is unique
@portal_admin_bp.route('/check-details-unique/<user_type>/<field>', methods=['POST'])
@login_required
def check_details_unique(user_type, field):

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return 'unsuccessful', 401

    userID = request.get_json()["userID"]
    currentInput = request.get_json()["currentInput"]

    if user_type == "app":
        if field == "email":
            count = AppUser.query\
                           .filter(AppUser.email == currentInput)\
                           .filter(AppUser.userID != userID)\
                           .count()
        elif field == "username":
            count = AppUser.query\
                           .filter(AppUser.username == currentInput)\
                           .filter(AppUser.userID != userID)\
                           .count()
    
    elif user_type == "SRO":
        if field == "email":
            count = SRO.query\
                        .filter(SRO.email == currentInput)\
                        .filter(SRO.sroID != userID)\
                        .count()
        elif field == "username":
            count = SRO.query\
                       .filter(SRO.username == currentInput)\
                       .filter(SRO.sroID != userID)\
                       .count()

    message = 'unique' if count == 0 else 'not_unique'

    return message


# Add a new app user account
@portal_admin_bp.route('/add-app-account', methods=['POST'])
@login_required
def add_app_account():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return 'unsuccessful', 401

    firstName = request.get_json()['firstName']
    lastName = request.get_json()['lastName']
    email = request.get_json()['email']
    username = request.get_json()['username']
    sroID = request.get_json()['sroID']

    new_password = get_new_password()
    hashed_password = generate_password_hash(new_password)

    new_account = AppUser(firstName=firstName,
                          lastName=lastName,
                          email=email,
                          password=hashed_password,
                          username=username,
                          sroID=sroID)

    db.session.add(new_account)
    db.session.commit()

    allocated_sro = SRO.query.get(sroID)
    sroName = allocated_sro.firstName + ' ' + allocated_sro.lastName

    # Send email with login details
    msg = Message("MobileV - Welcome!", recipients=[email])
    msg.html = """
        <h2>Mobile<span style="font-weight: normal">V</span></h2>
        <img src='https://drive.google.com/uc?id=1rMbHcxETdn7hkPwKgi2SKy-IiN1g04Ma' width='100' height='82'>
        <p>Dear {},</p>
        <p>A MobileV app account has just been created for you, associated with {}.</p>
        <p><b>Username:</b> {}<br>
        <b>Password:</b> {}</p>
        <p>Please remember to change your password after you log in.</p>
        <p>Best wishes,</p>
        <p>The <b>Mobile</b>V team
        """.format(firstName, sroName, username, new_password)

    mail.send(msg)

    return 'success'


# Add a new SRO account
@portal_admin_bp.route('/add-SRO-account', methods=['POST'])
@login_required
def add_SRO_account():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return 'unsuccessful', 401

    firstName = request.get_json()['firstName']
    lastName = request.get_json()['lastName']
    email = request.get_json()['email']
    username = request.get_json()['username']

    new_password = get_new_password()
    hashed_password = generate_password_hash(new_password)

    new_account = SRO(firstName=firstName,
                      lastName=lastName,
                      email=email,
                      password=hashed_password,
                      username=username)

    db.session.add(new_account)
    db.session.commit()

    # Send email with login details
    link = url_for('auth_bp.login_portal', _external=True)
    msg = Message("MobileV - Welcome!", recipients=[email])
    msg.html = """
        <h2>Mobile<span style="font-weight: normal">V</span></h2>
        <img src='https://drive.google.com/uc?id=1rMbHcxETdn7hkPwKgi2SKy-IiN1g04Ma' width='100' height='82'>
        <p>Dear {},</p>
        <p>A MobileV SRO account has just been created for you.</p>
        <p><b>Username:</b> {}<br>
        <b>Password:</b> {}</p>
        <p>You can log in to the system <a href="{}">here</a>.</p>
        <p>Please remember to change your password after you log in.</p>
        <p>Best wishes,</p>
        <p>The <b>Mobile</b>V team
        """.format(firstName, username, new_password, link)

    mail.send(msg)

    return 'success'


# Update app user account details
@portal_admin_bp.route('/update-app-account/<userID>', methods=['POST'])
@login_required
def update_app_account(userID):

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return 'unsuccessful', 401

    user = AppUser.query.get(userID)

    user.firstName = request.get_json()['firstName']
    user.lastName = request.get_json()['lastName']
    user.email = request.get_json()['email']
    user.sroID = request.get_json()['sroID']

    db.session.commit()

    return 'success'


# Update SRO account details
@portal_admin_bp.route('/update-SRO-account/<sroID>', methods=['POST'])
@login_required
def update_SRO_account(sroID):

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return 'unsuccessful', 401

    user = SRO.query.get(sroID)

    user.firstName = request.get_json()['firstName']
    user.lastName = request.get_json()['lastName']
    user.email = request.get_json()['email']
    user.username = request.get_json()['username']

    db.session.commit()

    return 'success'


# Delete app user account
@portal_admin_bp.route('/delete-app-account', methods=['POST'])
@login_required
def delete_app_account():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return 'unsuccessful', 401

    userID = request.get_json()['userID']

    user = AppUser.query.get(userID)

    # Delete any shared files from storage
    shares = Share.query\
                  .filter(Share.userID == 1)\
                  .with_entities(Share.filePath)\
                  .all()

    for filePath in shares:
        if os.path.exists(filePath[0]):
            os.remove(filePath[0])

    # Delete user account and information
    db.session.delete(user)
    db.session.commit()

    return 'success'


# Delete SRO account
@portal_admin_bp.route('/delete-SRO-account', methods=['POST'])
@login_required
def delete_SRO_account():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return 'unsuccessful', 401

    sroID = request.get_json()['sroID']

    user = SRO.query.get(sroID)

    db.session.delete(user)
    db.session.commit()

    return 'success'


# Change IBM Watson STT API key and service URL
@portal_admin_bp.route('/change-IBM-credentials', methods=['POST'])
@login_required
def change_IBM_credentials():

    # Redirect if logged in as SRO
    if current_user.get_role() == 'SRO':
        return 'unsuccessful', 401

    new_apiKey = request.get_json()["new_apiKey"]
    new_serviceURL = request.get_json()["new_serviceURL"]

    current_creds = IBMCred.query.first()

    if current_creds is not None and (new_apiKey, new_serviceURL) != ("", ""):
        current_creds.apiKey = new_apiKey
        current_creds.serviceURL = new_serviceURL
        db.session.commit()
        return 'successful'
    
    elif (new_apiKey, new_serviceURL) != ("", ""):
        new_creds = IBMCred(apiKey=new_apiKey, serviceURL=new_serviceURL)
        db.session.add(new_creds)
        db.session.commit()
        return 'successful'

    return 'unsuccessful'


# Helper function to generate a semi-strong password on account creation
def get_new_password():
    password = ""
    password += random.choice(string.ascii_uppercase)
    for i in range(5):
        password += random.choice(string.ascii_lowercase)
    password += str(random.randint(0, 9))
    return password

