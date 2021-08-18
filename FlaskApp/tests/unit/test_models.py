### models.py

from MobileV.models import *


## TESTING ENCRYPTION KEY BACKUP LOADER ---------------------------------------

def test_encryption_key_loader():
    loaded_encryption_key = get_encryption_key()
    assert loaded_encryption_key != None
    assert key != None


## TESTING AUTHENTICATION USER LOADERS ----------------------------------------

def test_user_identity_loader(new_app_user):
    loaded_id = user_identity_lookup(new_app_user)
    assert loaded_id == 1


## TESTING MODEL INSTANCE CREATION --------------------------------------------

# When a new Admin is created check fields defined correctly
def test_new_admin(new_admin):
    assert new_admin.adminID == 1
    assert new_admin.adminID == new_admin.get_id()
    assert new_admin.username == 'testUsername'
    assert new_admin.check_password('testPassword') == False
    assert new_admin.get_role() == 'Admin'


# When a new SRO is created check fields defined correctly
def test_new_SRO(new_SRO):
    assert new_SRO.sroID == 4
    assert new_SRO.sroID == new_SRO.get_id()
    assert new_SRO.username == 'testUsername'
    assert new_SRO.email == 'testEmail'
    assert new_SRO.check_password('testPassword') == False
    assert new_SRO.firstName == 'testFirstName'
    assert new_SRO.lastName == 'testLastName'
    assert new_SRO.get_role() == 'SRO'


# When a new AppUser is created check fields defined correctly
def test_new_app_user(new_app_user):
    assert new_app_user.userID == 1
    assert new_app_user.userID == new_app_user.get_id()
    assert new_app_user.username == 'testUsername'
    assert new_app_user.email == 'testEmail'
    assert new_app_user.check_password('testPassword') == False
    assert new_app_user.firstName == 'testFirstName'
    assert new_app_user.lastName == 'testLastName'
    assert new_app_user.sroID == 1
    assert new_app_user.get_role() == 'App'


# When a new IBMCred is created check fields defined correctly
def test_new_ibm_cred(new_ibm_cred):
    assert new_ibm_cred.apiKey == 'testApiKey'
    assert new_ibm_cred.serviceURL == 'testServiceUrl'


# When a new Share is created check fields defined correctly
def test_new_share(new_share):
    assert new_share.dateRecorded == '2021-08-12 12:00:00'
    assert new_share.type == 'Numeric'
    assert new_share.duration == 30
    assert new_share.WPM == 100
    assert new_share.score1_name == 'testScore1Name'
    assert new_share.score1_value == 1
    assert new_share.score2_name == 'testScore2Name'
    assert new_share.score2_value == 2
    assert new_share.score3_name == 'testScore3Name'
    assert new_share.score3_value == 3
    assert new_share.fileType == 'Audio'
    assert new_share.filePath == '/test/path'
    assert new_share.userID == 1


# When a new Score is created check fields defined correctly
def test_new_score(new_score):
    assert new_score.scoreName == 'testScoreName'
    assert new_score.userID == 1


# When a new PendingDownload is created check fields defined correctly
def test_new_pending_download(new_pending_download):
    assert new_pending_download.userID == 1
    assert new_pending_download.dateRecorded == '2021-08-12 12:00:00'
    assert new_pending_download.WPM == 100
    assert new_pending_download.transcript == 'testTranscript'
    assert new_pending_download.wordCloudPath == '/test/path'
    assert new_pending_download.status == 'success'


## TESTING ENCRYPTION & DECRYPTION --------------------------------------------

def test_encryption_helpers():
    filePath = 'MobileV/shares/dummy_data/test.mp3'
    loaded_bytes = decrypt_and_load(filePath)
    encrypt_and_save(loaded_bytes, filePath)
    encrypt_and_decrypt_bytes = decrypt_and_load(filePath)

    assert loaded_bytes == encrypt_and_decrypt_bytes

