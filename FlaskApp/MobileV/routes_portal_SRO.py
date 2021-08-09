### ROUTES RELATED TO PORTAL SRO USERS
# - Rendering templates
# - AJAX requests

from flask import Blueprint, render_template, redirect, url_for, jsonify, request, send_file
from flask_login import login_required, current_user
from sqlalchemy import func, distinct
from MobileV.models import *
import os, io

# Create blueprint for these routes
portal_SRO_bp = Blueprint('portal_SRO_bp', __name__, template_folder="templates", static_folder="static")


## RENDERING TEMPLATES --------------------------------------------------------

@portal_SRO_bp.route('/SRO-dashboard', methods=["GET"])
@login_required
def SRO_dashboard():

    # Redirect if logged in as Admin
    if current_user.get_role() == 'Admin':
        return redirect(url_for('portal_admin_bp.admin_accounts_app'))

    user = SRO.query.get(current_user.get_id())
    name = user.firstName + ' ' + user.lastName

    return render_template('SRO-dashboard.html', name=name)


@portal_SRO_bp.route('/SRO-change-password', methods=["GET"])
@login_required
def SRO_change_password():

    # Redirect if logged in as Admin
    if current_user.get_role() == 'Admin':
        return redirect(url_for('portal_admin_bp.admin_accounts_app'))

    user = SRO.query.get(current_user.get_id())
    name = user.firstName + ' ' + user.lastName

    return render_template('SRO-change-password.html', name=name)


## AJAX REQUESTS --------------------------------------------------------------

# Get a specific SRO's list of app users
@portal_SRO_bp.route('/get-SRO-app-users', methods=['GET'])
@login_required
def get_SRO_app_users():

    # Redirect if logged in as Admin
    if current_user.get_role() == 'Admin':
        return redirect(url_for('portal_admin_bp.admin_accounts_app'))

    sroID = current_user.get_id()

    users = AppUser.query\
                   .join(SRO.appUsers)\
                   .join(AppUser.shares, isouter=True)\
                   .join(AppUser.scores, isouter=True)\
                   .filter(AppUser.sroID == sroID)\
                   .group_by(AppUser.userID)\
                   .with_entities(AppUser.userID,
                                  AppUser.firstName,
                                  AppUser.lastName,
                                  AppUser.username,
                                  func.count(distinct(Share.dateRecorded)).label('NumShares'),
                                  func.max(Share.dateRecorded).label('MostRecent'))\
                   .all()

    data = [dict(row) for row in users]

    return jsonify(data), 200


# Get a list of a specific SRO's app user's allocated scoring domains
@portal_SRO_bp.route('/get-app-user-scores/<userID>', methods=['GET'])
@login_required
def get_app_user_scores(userID):

    # Redirect if logged in as Admin
    if current_user.get_role() == 'Admin':
        return redirect(url_for('portal_admin_bp.admin_accounts_app'))
    
    # Redirect if the user is not allocated to logged in SRO
    sroID = current_user.get_id()
    user = AppUser.query.get(userID)
    if user.sroID != sroID:
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    scores = AppUser.query\
                    .join(AppUser.scores)\
                    .filter(AppUser.userID == userID)\
                    .with_entities(Score.scoreID,
                                   Score.scoreName)\
                    .order_by(Score.scoreID.asc())\
                    .all()

    data = [dict(row) for row in scores]

    return jsonify(data), 200


# Update an app user's allocated scores
@portal_SRO_bp.route('/update-app-user-scores/<userID>', methods=['POST'])
@login_required
def update_app_user_scores(userID):

    # Redirect if logged in as Admin
    if current_user.get_role() == 'Admin':
        return 'unsuccessful', 401

    # Redirect if the user is not allocated to logged in SRO
    sroID = current_user.get_id()
    user = AppUser.query.get(userID)
    if user.sroID != sroID:
        return 'unsuccessful', 401

    inserted = request.get_json()['inserted']
    updated = request.get_json()['updated']
    deleted = request.get_json()['deleted']

    # Insert new scores
    new_scores = []
    for scoreName in inserted:
        new_scores.append(Score(scoreName=scoreName, userID=userID))
    db.session.add_all(new_scores)

    # Update scores
    for scoreID in updated.keys():
        score = Score.query.get(scoreID)
        score.scoreName = updated[scoreID]

    # Delete scores
    for scoreID in deleted:
        score = Score.query.get(scoreID)
        db.session.delete(score)

    db.session.commit()

    return 'success'


# Get a list of a specific SRO's app user's shares
@portal_SRO_bp.route('/get-app-user-shares/<userID>', methods=['GET'])
@login_required
def get_app_user_shares(userID):

    # Redirect if logged in as Admin
    if current_user.get_role() == 'Admin':
        return redirect(url_for('portal_admin_bp.admin_accounts_app'))

    # Redirect if the user is not allocated to logged in SRO
    sroID = current_user.get_id()
    user = AppUser.query.get(userID)
    if user.sroID != sroID:
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    shares = AppUser.query\
                    .join(AppUser.shares)\
                    .filter(AppUser.userID == userID)\
                    .with_entities(Share.shareID,
                                   Share.dateRecorded,
                                   Share.type,
                                   Share.duration,
                                   Share.WPM,
                                   Share.score1_name,
                                   Share.score1_value,
                                   Share.score2_name,
                                   Share.score2_value,
                                   Share.score3_name,
                                   Share.score3_value,
                                   Share.fileType)\
                    .order_by(Share.dateRecorded.desc())\
                    .all()

    data = [dict(row) for row in shares]

    return jsonify(data), 200


# Download an app user's share
@portal_SRO_bp.route('/download-app-user-share/<shareID>', methods=['GET'])
@login_required
def download_app_user_share(shareID):

    # Redirect if logged in as Admin
    if current_user.get_role() == 'Admin':
        return redirect(url_for('portal_admin_bp.admin_accounts_app'))

    # Redirect if the user is not allocated to logged in SRO
    sroID = current_user.get_id()
    share = Share.query.get(shareID)
    user = AppUser.query.get(share.userID)
    if user.sroID != sroID:
        return redirect(url_for('portal_SRO_bp.SRO_dashboard'))

    if os.path.exists(share.filePath):

        # Open and decrypt file; store in local variable
        file_bytes = io.BytesIO(decrypt(share.filePath))

        # Construct download name, accounting for nulls
        name_pt1 = "{}_{}_{}_{}s_WPM_{}".format(share.dateRecorded.date(),
                                                share.fileType, 
                                                share.type,
                                                share.duration,
                                                share.WPM)
        
        def conv_none(_input):
            return '' if _input is None else '_' + str(_input)
        
        name_pt2 = "{}{}{}{}{}{}".format(conv_none(share.score1_name),
                                         conv_none(share.score1_value),
                                         conv_none(share.score2_name),
                                         conv_none(share.score2_value),
                                         conv_none(share.score3_name),
                                         conv_none(share.score3_value))
        
        extension = share.filePath[-4:]
        name = name_pt1 + name_pt2 + extension

        return send_file(file_bytes, as_attachment=True, download_name=name)

    return 'unsuccessful'


# Delete an app user's share
@portal_SRO_bp.route('/delete-app-user-share', methods=['POST'])
@login_required
def delete_app_user_share():

    # Redirect if logged in as Admin
    if current_user.get_role() == 'Admin':
        return 'unsuccessful', 401

    shareID = request.get_json()['shareID']

    # Redirect if the user is not allocated to logged in SRO
    sroID = current_user.get_id()
    share = Share.query.get(shareID)
    user = AppUser.query.get(share.userID)
    if user.sroID != sroID:
        return 'unsuccessful', 401

    if os.path.exists(share.filePath):
        os.remove(share.filePath)
        db.session.delete(share)
        db.session.commit()
        return 'success'

    return 'unsuccessful'

