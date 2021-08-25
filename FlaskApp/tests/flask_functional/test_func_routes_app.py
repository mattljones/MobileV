### Functional tests for routes_app.py

from MobileV.models import *
from MobileV.stt import decrypt_and_load
from flask import json
from conftest import login_app
import io, base64


# Test that recording upload works correctly
def test_transcribe_analyse(client):
    # Collect access token from login
    response = login_app(client)
    data = json.loads(response.data)
    access_token = data['accessToken']
    headers = {'Authorization': 'Bearer {}'.format(access_token)}

    # Construct base64 string of example audio file
    audio_bytes = io.BytesIO(decrypt_and_load('MobileV/shares/dummy_data/test.mp3'))
    base64_bytes = base64.b64encode(audio_bytes.getvalue())
    base64_string = base64_bytes.decode('utf-8')

    response = client.post('/transcribe-analyse', headers=headers, json={
        'dateRecorded': '2021-08-13 12:00:00',
        'type': 'Text',
        'duration': '30',
        'score1_name': 'Score1',
        'score1_value': '1',
        'score2_name': 'Score2',
        'score2_value': '2',
        'score3_name': 'Score3',
        'score3_value': '3',
        'shareType': 'both',
        'audioFile': base64_string,
        'refNumber': ''
    })

    assert b'successful' in response.data


# Test that downloading recording analysis works correctly
def test_get_analysis(client):
    # Collect access token from login
    response = login_app(client)
    data = json.loads(response.data)
    access_token = data['accessToken']
    headers = {'Authorization': 'Bearer {}'.format(access_token)}

    # Analysis incomplete (ie missing from table)
    response = client.post('/get-analysis', headers=headers, json={
        'dateRecorded': '1900-08-12 12:00:00',
    })
    data = json.loads(response.data)
    assert data['status'] == 'incomplete'

    # Analysis complete, no wordcloud
    response = client.post('/get-analysis', headers=headers, json={
        'dateRecorded': '2021-08-11 12:00:00.000000',
    })
    data = json.loads(response.data)
    assert data['status'] == 'success'

    # Analysis complete, failed to load wordcloud
    response = client.post('/get-analysis', headers=headers, json={
        'dateRecorded': '2021-08-12 12:00:00.000000',
    })
    data = json.loads(response.data)
    assert data['status'] == 'failed'


# Test that updating recording scores works correctly
def test_update_recording_scores(client):
    # Collect access token from login
    response = login_app(client)
    data = json.loads(response.data)
    access_token = data['accessToken']

    dummyDate = '2021-08-12 12:00:00.000000'

    headers = {'Authorization': 'Bearer {}'.format(access_token)}
    response = client.post('/update-recording-scores', headers=headers, json={
        'dateRecorded': dummyDate,
        'new_score1_value': 1,
        'new_score2_value': 2,
        'new_score3_value': 3
    })

    assert b'successful' in response.data

    # Check database updated correctly
    shares = Share.query.filter(Share.dateRecorded == dummyDate).all()
    for share in shares:
        assert share.score1_value == 1
        assert share.score2_value == 2
        assert share.score3_value == 3


# Test downloading names for the app profile tab
def test_get_names(client):
    # Collect access token from login
    response = login_app(client)
    data = json.loads(response.data)
    access_token = data['accessToken']

    headers = {'Authorization': 'Bearer {}'.format(access_token)}
    response = client.get('/get-names', headers=headers)
    assert response.status_code == 200


# Test downloading latest scoring fields for adding a recording in the app
def test_get_scores(client):
    # Collect access token from login
    response = login_app(client)
    data = json.loads(response.data)
    access_token = data['accessToken']

    headers = {'Authorization': 'Bearer {}'.format(access_token)}
    response = client.get('/get-scores', headers=headers)
    assert response.status_code == 200

