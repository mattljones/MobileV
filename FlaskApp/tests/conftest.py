### TEST CONFIGURATION

# Add project root to path
from pathlib import Path
from os import environ
import sys
root_path = Path(__file__).parents[1]
sys.path.insert(0, str(root_path))

# Imports
from MobileV import create_app
from MobileV.models import *
from MobileV.db_generate import seed_all
from datetime import datetime
import pytest


## TESTING CLIENT FIXTURE -----------------------------------------------------

@pytest.fixture(scope='module')
def client():
    app = create_app('test')

    with app.test_client() as client:
        with app.app_context():

            # Create database for use in testing from dummy data
            db.drop_all()
            db.create_all()
            seed_all(test=True)
            seed_extra()

            yield client


## MODEL FIXTURES -------------------------------------------------------------

@pytest.fixture(scope='module')
def new_admin():
    admin = Admin(adminID=1, username='testUsername', password='testPassword')
    return admin


@pytest.fixture(scope='module')
def new_SRO():
    sro = SRO(sroID=4,
              username='testUsername',
              email='testEmail', 
              password='testPassword',
              firstName='testFirstName',
              lastName='testLastName')

    return sro


@pytest.fixture(scope='module')
def new_app_user():
    user = AppUser(userID=1,
                   username='testUsername',
                   email='testEmail', 
                   password='testPassword',
                   firstName='testFirstName',
                   lastName='testLastName',
                   sroID=1)

    return user


@pytest.fixture(scope='module')
def new_ibm_cred():
    cred = IBMCred(apiKey='testApiKey', serviceURL='testServiceUrl')
    return cred


@pytest.fixture(scope='module')
def new_share():
    share = Share(dateRecorded='2021-08-12 12:00:00',
                  type='Numeric', 
                  duration=30,
                  WPM=100,
                  score1_name='testScore1Name',
                  score1_value=1,
                  score2_name='testScore2Name',
                  score2_value=2,
                  score3_name='testScore3Name',
                  score3_value=3,
                  fileType='Audio',
                  filePath='/test/path',
                  userID=1)

    return share


@pytest.fixture(scope='module')
def new_score():
    score = Score(scoreName='testScoreName', userID=1)
    return score


@pytest.fixture(scope='module')
def new_pending_download():
    pending = PendingDownload(userID=1,
                              dateRecorded='2021-08-12 12:00:00',
                              WPM=100,
                              transcript='testTranscript',
                              wordCloudPath='/test/path',
                              status='success')

    return pending


## LOGIN/LOGOUT HELPERS--------------------------------------------------------

def login_portal_as_admin(client, fail=False):

    # Load dummy account details from .env
    from dotenv import load_dotenv
    load_dotenv('.env')

    username = environ.get('TEST_ADMIN_USERNAME') if fail == False else 'incorrectUsername'

    return client.post('/login/portal', json={
        'user_type': 'Admin',
        'username': username,
        'password': environ.get('TEST_ADMIN_PASSWORD'),
        'remember_me': '0',
        'next_page': ''
    }, follow_redirects=True)


def login_portal_as_SRO(client, fail=False):

    # Load dummy account details from .env
    from dotenv import load_dotenv
    load_dotenv('.env')

    username = environ.get('TEST_SRO_USERNAME') if fail == False else 'incorrectUsername'

    return client.post('/login/portal', json={
        'user_type': 'SRO',
        'username': username,
        'password': environ.get('TEST_SRO_PASSWORD'),
        'remember_me': '0',
        'next_page': ''
    }, follow_redirects=True)


def login_app(client, fail=False):

    # Load dummy account details from .env
    from dotenv import load_dotenv
    load_dotenv('.env')

    username = environ.get('TEST_APP_USERNAME') if fail == False else 'incorrectUsername'

    return client.post('/login/app', json={
        'username': username,
        'password': environ.get('TEST_APP_PASSWORD')
    }, follow_redirects=True)


def logout_portal(client):
    return client.get('/logout', follow_redirects=True)


## EXTRA HELPERS --------------------------------------------------------------

# SQLite only accepts python datetime objects so seed these manually
def seed_extra():

    pending_noCloud = PendingDownload(userID=1, 
                                      dateRecorded=datetime.strptime('2021-08-11 12:00:00', '%Y-%m-%d %H:%M:%S'),
                                      WPM=100,
                                      transcript=None,
                                      wordCloudPath=None,
                                      status='success')

    pending_Cloud = PendingDownload(userID=1,
                                    dateRecorded=datetime.strptime('2021-08-12 12:00:00', '%Y-%m-%d %H:%M:%S'),
                                    WPM=100,
                                    transcript='dummyTranscript',
                                    wordCloudPath='incorrectPath',
                                    status='success')

    share_real = Share(dateRecorded=datetime.strptime('2021-08-12 12:00:00', '%Y-%m-%d %H:%M:%S'),
                       type='Numeric',
                       duration=30,
                       WPM=100,
                       fileType='Audio',
                       filePath='MobileV/shares/dummy_data/test.mp3',
                       userID=1)

    share_fake = Share(dateRecorded=datetime.strptime('2021-08-12 12:00:00', '%Y-%m-%d %H:%M:%S'),
                       type='Numeric',
                       duration=30,
                       WPM=100,
                       fileType='Audio',
                       filePath='MobileV/shares/dummy_data/fake.mp3',
                       userID=1)

    db.session.add(pending_noCloud)
    db.session.add(pending_Cloud)
    db.session.add(share_real)
    db.session.add(share_fake)
    db.session.commit()

    