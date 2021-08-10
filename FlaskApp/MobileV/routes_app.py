### ROUTES RELATED TO THE MOBILE APP

from MobileV.models import *
from flask import Blueprint, json, request, Response, jsonify, copy_current_request_context
from threading import Thread
import MobileV.ibm_stt as ibm_stt
import io, gc

# Create blueprint for these routes
app_bp = Blueprint('app_bp', __name__)


# Main transcription route
@app_bp.route('/transcribe', methods=["POST"])
def transcribe():

    @copy_current_request_context
    def handover():

        temp_file = io.BytesIO(request.get_data())
        converted_file = ibm_stt.convert_to_mp3(temp_file)

        ibm_creds = IBMCred.query.first()
        ibm_stt.get_transcript(converted_file, ibm_creds.apiKey, ibm_creds.serviceURL)

        del temp_file
        del converted_file
        gc.collect()
        

    Thread(target=handover).start()

    return Response(status=200)


# Get the user's first name and current SRO name
@app_bp.route('/get-names', methods=["GET"])
def get_names():
    user = AppUser.query.filter_by(username='MobileVUser1').first()
    sro = SRO.query.get(user.sroID)

    dict = {
        'firstName': user.firstName,
        'SRO': sro.firstName + ' ' + sro.lastName
    }

    return jsonify(dict)


# Get the user's currently allocated scores
@app_bp.route('/get-scores', methods=["GET"])
def get_scores():
    user = AppUser.query.filter_by(username='MobileVUser1').first()
    scores = {}
    for score in user.scores:
        dict = score.__dict__
        scores[dict['scoreID']] = dict['scoreName']

    return jsonify(scores)

