### TEST CONFIGURATION

# Add project root to path
from pathlib import Path
import sys
root_path = Path(__file__).parents[1]
sys.path.insert(0, str(root_path))

# Imports
from MobileV.models import *
import pytest


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

