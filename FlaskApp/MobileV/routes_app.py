### ROUTES RELATED TO THE MOBILE APP

from datetime import datetime
from flask import Blueprint, request, jsonify, current_app as app
from flask_jwt_extended import jwt_required, current_user as current_user_jwt
from MobileV import create_app
from MobileV.models import *
from threading import Thread
import MobileV.stt as stt
import io, base64, copy

# Create blueprint for these routes
app_bp = Blueprint('app_bp', __name__)


# Main speech-to-text route
@app_bp.route('/transcribe-analyse', methods=["POST"])
@jwt_required()
def transcribe_analyse():

    # Pass recording data to new thread
    recording_data = request.get_json()

    # Pass environment type to new thread (so correct app can be pushed in new thread)
    if app.config['ENV'] == 'production':
        env = 'prod'
    else:
        if app.config['TESTING'] == True:
            env = 'test'
            # Convert datetime to object if testing (SQLite only accepts datetime objects)
            recording_data['dateRecorded'] = datetime.strptime(recording_data['dateRecorded'], '%Y-%m-%d %H:%M:%S')
        else:
            env = 'dev'

    # Pass userID to new thread
    user = current_user_jwt
    userID = user.userID

    # Start new thread to handle the transcription, word cloud creation and encryption...
    # ... so users can receive instant (async) feedback that their upload was successful
    Thread(target=handover, args=[env, userID, recording_data]).start()

    return 'successful'


# Function called in a separate thread from above to complete the transcription & analysis
def handover(env, userID, recording_data):

    # Push application context
    app = create_app(env)
    app.app_context().push()
    
    # Collect data from request, accounting for missing data
    dateRecorded = recording_data['dateRecorded']
    type = recording_data['type']
    duration = recording_data['duration']
    score1_name = recording_data['score1_name'] if recording_data['score1_name'] != '' else None
    score1_value = recording_data['score1_value'] if recording_data['score1_value'] != '' else None
    score2_name = recording_data['score2_name'] if recording_data['score2_name'] != '' else None
    score2_value = recording_data['score2_value'] if recording_data['score2_value'] != '' else None
    score3_name = recording_data['score3_name'] if recording_data['score3_name'] != '' else None
    score3_value = recording_data['score3_value'] if recording_data['score3_value'] != '' else None
    shareType = recording_data['shareType']
    base64audio = recording_data['audioFile']
    refNumber = recording_data['refNumber'] if recording_data['refNumber'] != '' else None

    # Generate unique & valid filename for storing audio/wordclouds
    if env != 'test':
        fileName = '{}_'.format(userID) + dateRecorded.replace(' ', '_').replace(':','-')
    else:
        fileName = 'testPath'
        
    audioPath = 'MobileV/shares/{}.mp3'.format(fileName)
    wordCloudPath = 'MobileV/shares/{}.png'.format(fileName)

    # Convert base64-encoded audio to a file, then convert to mp3
    temp_audio = io.BytesIO(base64.b64decode(base64audio))
    converted_audio = stt.convert_to_mp3(temp_audio)
    converted_audio_ibm = copy.copy(converted_audio) # stt.get_transcript() closes file once complete

    # Get transcript
    ibm_creds = IBMCred.query.first()
    
    # Try to use the IBM STT API for transcription
    try: 
        transcript = stt.get_transcript(converted_audio_ibm, ibm_creds.apiKey, ibm_creds.serviceURL)

    # In the case of an error, signal this to the app in the database (so it doesn't poll indefinitely)
    except Exception:
        pendingDownloadError = PendingDownload(
            userID=userID,
            dateRecorded=dateRecorded,
            WPM=None,
            transcript=None,
            wordCloudPath=None,
            status='failed'
        )
        db.session.add(pendingDownloadError)

    # Otherwise, analyse the transcript and save/share based on user share preferences
    else:
        # Calculate WPM (Text & Numeric)
        noWords = len(transcript.split())
        minutes = int(duration) / 60
        WPM = round(noWords/minutes)

        # Create and save word cloud (Text only)
        if type == 'Text' and noWords != 0:
            stt.generate_save_wordcloud(transcript, wordCloudPath)

        # Insert new PendingDownload
        transcript = transcript if type == 'Text' and noWords != 0 else None
        wordCloudPath = wordCloudPath if type == 'Text' and noWords != 0 else None
        pendingDownload = PendingDownload(
            userID=userID,
            dateRecorded=dateRecorded,
            WPM=WPM,
            transcript=transcript,
            wordCloudPath=wordCloudPath,
            status='success'
        )
        db.session.add(pendingDownload)

        # Insert new word cloud share if appropriate
        if (shareType == 'wordCloud' or shareType == 'both') and type == 'Text' and noWords != 0:
            wordCloudShare = Share(
                dateRecorded=dateRecorded,
                type=type,
                duration=int(duration),
                WPM=WPM,
                score1_name=score1_name,
                score1_value=score1_value,
                score2_name=score2_name,
                score2_value=score2_value,
                score3_name=score3_name,
                score3_value=score3_value,
                fileType='Word Cloud',
                filePath=wordCloudPath,
                refNumber=refNumber,
                userID=userID
            )
            db.session.add(wordCloudShare)

        # Insert new audio share if appropriate
        if shareType == 'audio' or shareType == 'both':
            audioShare = Share(
                dateRecorded=dateRecorded,
                type=type,
                duration=int(duration),
                WPM=WPM,
                score1_name=score1_name,
                score1_value=score1_value,
                score2_name=score2_name,
                score2_value=score2_value,
                score3_name=score3_name,
                score3_value=score3_value,
                fileType='Audio',
                filePath=audioPath,
                refNumber=refNumber,
                userID=userID
            )
            db.session.add(audioShare)
            # Save (and encrypt) audio buffer if shared
            encrypt_and_save(converted_audio.getvalue(), audioPath)

    # Commit everything to the database
    finally:
        db.session.commit()


# Get recording analysis once it's ready
@app_bp.route('/get-analysis', methods=["POST"])
@jwt_required()
def get_analysis():

    dateRecorded = request.get_json()['dateRecorded']
    user = current_user_jwt

    analysis = PendingDownload.query\
                              .filter(PendingDownload.dateRecorded == dateRecorded)\
                              .filter(PendingDownload.userID == user.userID)\
                              .first()

    # If not ready, notify app    
    if analysis == None:
        dict = {
            'status': 'incomplete'
        }

    # Otherwise, return analysis
    else:

        # Construct valid strings for response
        WPM = str(analysis.WPM) if analysis.WPM != None else ''
        transcript = analysis.transcript if analysis.transcript != None else ''
        
        # No word cloud created (Numeric recording, or an unexpected error)
        if analysis.wordCloudPath == None: 
            dict = {
                'status': analysis.status,
                'WPM': WPM,
                'transcript': transcript,
                'wordCloud': '',
            }

        # Load word cloud and convert to base 64-encoded string
        else:
            try: 
                cloud_bytes = io.BytesIO(decrypt_and_load(analysis.wordCloudPath))
            except:
                dict = {
                    'status': 'failed'
                }
            else: 
                base64_bytes = base64.b64encode(cloud_bytes.getvalue())
                base64_string = base64_bytes.decode('utf-8')
                dict = {
                    'status': analysis.status,
                    'WPM': WPM,
                    'transcript': transcript,
                    'wordCloud': base64_string,
                }

    return jsonify(dict)


# Update a recording's scores
@app_bp.route('/update-recording-scores', methods=["POST"])
@jwt_required()
def update_recording_scores():

    dateRecorded = request.get_json()['dateRecorded']
    new_score1_value = request.get_json()['new_score1_value']
    new_score1_value = new_score1_value if new_score1_value != '' else None
    new_score2_value = request.get_json()['new_score2_value']
    new_score2_value = new_score2_value if new_score2_value != '' else None
    new_score3_value = request.get_json()['new_score3_value']
    new_score3_value = new_score3_value if new_score3_value != '' else None

    user = current_user_jwt

    shares = Share.query\
                  .filter(Share.dateRecorded == dateRecorded)\
                  .filter(Share.userID == user.userID)\
                  .all()

    for share in shares:
        if app.config['TESTING'] == False:
            share.dateRecorded = dateRecorded
        share.score1_value = new_score1_value
        share.score2_value = new_score2_value
        share.score3_value = new_score3_value

    db.session.commit()

    return 'successful'


# Get the user's first name and current SRO name
@app_bp.route('/get-names', methods=["GET"])
@jwt_required()
def get_names():
    user = current_user_jwt
    sro = SRO.query.get(user.sroID)

    dict = {
        'firstName': user.firstName,
        'SRO': sro.firstName + ' ' + sro.lastName
    }

    return jsonify(dict)


# Get the user's currently allocated scores
@app_bp.route('/get-scores', methods=["GET"])
@jwt_required()
def get_scores():
    user = current_user_jwt
    scores = {}
    for score in user.scores:
        dict = score.__dict__
        scores[dict['scoreID']] = dict['scoreName']

    return jsonify(scores)

