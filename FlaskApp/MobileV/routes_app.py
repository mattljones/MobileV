### ROUTES RELATED TO THE MOBILE APP

from MobileV.models import *
from flask import Blueprint, request, jsonify, copy_current_request_context
from threading import Thread
import MobileV.ibm_stt as ibm_stt
import io, gc, base64

# Create blueprint for these routes
app_bp = Blueprint('app_bp', __name__)


# Main transcription route
@app_bp.route('/transcribe', methods=["POST"])
def transcribe():

    @copy_current_request_context
    def handover():
        dateRecorded = request.get_json()['dateRecorded']
        type = request.get_json()['type']
        duration = request.get_json()['duration']
        score1_name = request.get_json()['score1_name']
        score1_value = request.get_json()['score1_value']
        score2_name = request.get_json()['score2_name']
        score2_value = request.get_json()['score2_value']
        score3_name = request.get_json()['score3_name']
        score3_value = request.get_json()['score3_value']
        shareType = request.get_json()['shareType']
        base64audio = request.get_json()['audioFile']

        # Convert base64-encoded audio to a file, then convert to mp3
        temp_file = io.BytesIO(base64.b64decode(base64audio))
        converted_file = ibm_stt.convert_to_mp3(temp_file)

        # Get transcript
        ibm_creds = IBMCred.query.first()
        transcript = ibm_stt.get_transcript(converted_file, ibm_creds.apiKey, ibm_creds.serviceURL)

        # Calculate WPM (Text & Numeric)

        # Create word cloud (Text only)

        # Save to disk

        # Save to database

        # Force clean-up of audio files from memory
        del temp_file
        del converted_file
        gc.collect()


    Thread(target=handover).start()

    return 'successful'


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

