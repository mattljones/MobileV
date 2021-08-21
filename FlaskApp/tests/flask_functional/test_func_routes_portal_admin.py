### Functional tests for routes_portal_admin.py

from conftest import login_as_admin_client, login_as_SRO_client, logout_portal
from MobileV.models import *


## TESTING PAGE LOADING -------------------------------------------------------

def test_app_accounts_page(client):

    login_as_admin_client(client)
    response = client.get('/admin-accounts-app')
    assert response.status_code == 200
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/admin-accounts-app')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


def test_SRO_accounts_page(client):

    login_as_admin_client(client)
    response = client.get('/admin-accounts-SRO')
    assert response.status_code == 200
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/admin-accounts-SRO')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


def test_change_IBM_page(client):

    login_as_admin_client(client)
    response = client.get('/admin-change-IBM')
    assert response.status_code == 200
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/admin-change-IBM')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


def test_admin_change_password_page(client):

    login_as_admin_client(client)
    response = client.get('/admin-change-password')
    assert response.status_code == 200
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/admin-change-password')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


## TESTING AJAX REQUESTS-------------------------------------------------------

def test_get_all_app_users(client):

    login_as_SRO_client(client)
    response = client.get('/get-all-app-users')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_admin_client(client)
    response = client.get('/get-all-app-users')
    assert response.status_code == 200
    logout_portal(client)


def test_get_single_app_user(client):

    login_as_SRO_client(client)
    response = client.get('/get-app-user-details/1')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_admin_client(client)
    response = client.get('/get-app-user-details/1')
    assert response.status_code == 200
    logout_portal(client)


def test_get_all_SROs(client):

    login_as_SRO_client(client)
    response = client.get('/get-all-SROs')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_admin_client(client)
    response = client.get('/get-all-SROs')
    assert response.status_code == 200
    logout_portal(client)


def test_get_single_SRO(client):

    login_as_SRO_client(client)
    response = client.get('/get-SRO-details/1')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_admin_client(client)
    response = client.get('/get-SRO-details/1')
    assert response.status_code == 200
    logout_portal(client)


def test_get_all_SRO_names(client):

    login_as_SRO_client(client)
    response = client.get('/get-all-SRO-names')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_admin_client(client)
    response = client.get('/get-all-SRO-names')
    assert response.status_code == 200
    logout_portal(client)


def test_check_details_unique(client):

    login_as_SRO_client(client)
    response = client.post('/check-details-unique/app/email')
    assert response.status_code == 401  
    logout_portal(client)

    login_as_admin_client(client)

    # App, email
    response = client.post('/check-details-unique/app/email', json={
        'userID': 1,
        'currentInput': 'testInput'
    })
    assert response.status_code == 200

    # App, username
    response = client.post('/check-details-unique/app/username', json={
        'userID': 1,
        'currentInput': 'testInput'
    })
    assert response.status_code == 200

    # SRO, email
    response = client.post('/check-details-unique/SRO/email', json={
        'userID': 4,
        'currentInput': 'alan.turing@enigma.com'
    })
    assert response.status_code == 200
    assert b'not_unique' in response.data

    # SRO, username
    response = client.post('/check-details-unique/SRO/username', json={
        'userID': 4,
        'currentInput': 'testInput'
    })
    assert response.status_code == 200
    assert b'unique' in response.data

    logout_portal(client)


def test_add_app_account(client):

    login_as_SRO_client(client)
    response = client.post('/add-app-account')
    assert response.status_code == 401 
    logout_portal(client)

    login_as_admin_client(client)
    response = client.post('/add-app-account', json={
        'firstName': 'firstName',
        'lastName': 'lastName',
        'email': 'email',
        'username': 'username',
        'sroID': 4
    })
    assert response.status_code == 200
    user = AppUser.query.filter(AppUser.username == 'username').first()
    assert user is not None

    logout_portal(client)


def test_add_SRO_account(client):

    login_as_SRO_client(client)
    response = client.post('/add-SRO-account')
    assert response.status_code == 401 
    logout_portal(client)

    login_as_admin_client(client)
    response = client.post('/add-SRO-account', json={
        'firstName': 'firstName',
        'lastName': 'lastName',
        'email': 'email',
        'username': 'username'
    })
    assert response.status_code == 200
    sro = SRO.query.filter(SRO.username == 'username').first()
    assert sro is not None

    logout_portal(client)


def test_update_app_account(client):

    login_as_SRO_client(client)
    response = client.post('/update-app-account/1')
    assert response.status_code == 401 
    logout_portal(client)

    login_as_admin_client(client)
    response = client.post('/update-app-account/1', json={
        'firstName': 'firstName',
        'lastName': 'lastName',
        'email': 'email',
        'sroID': 4
    })
    assert response.status_code == 200
    user = AppUser.query.get(1)
    assert user.firstName == 'firstName'
    assert user.lastName == 'lastName'
    assert user.email == 'email'
    assert user.sroID == 4

    logout_portal(client)


def test_update_SRO_account(client):

    login_as_SRO_client(client)
    response = client.post('/update-SRO-account/4')
    assert response.status_code == 401 
    logout_portal(client)

    login_as_admin_client(client)
    response = client.post('/update-SRO-account/5', json={
        'firstName': 'firstName',
        'lastName': 'lastName',
        'email': 'email',
        'username': 'username'
    })
    assert response.status_code == 200
    sro = SRO.query.get(5)
    assert sro.firstName == 'firstName'
    assert sro.lastName == 'lastName'
    assert sro.email == 'email'
    assert sro.username == 'username'

    logout_portal(client)


def test_delete_app_account(client):

    login_as_SRO_client(client)
    response = client.post('/delete-app-account')
    assert response.status_code == 401 
    logout_portal(client)

    login_as_admin_client(client)
    response = client.post('/delete-app-account', json={
        'userID': 2
    })
    assert response.status_code == 200
    user = AppUser.query.get(2)
    assert user is None

    logout_portal(client)


def test_delete_SRO_account(client):

    login_as_SRO_client(client)
    response = client.post('/delete-SRO-account')
    assert response.status_code == 401 
    logout_portal(client)

    login_as_admin_client(client)
    response = client.post('/delete-SRO-account', json={
        'sroID': 6
    })
    assert response.status_code == 200
    sro = SRO.query.get(6)
    assert sro is None

    logout_portal(client)


def test_change_IBM_credentials(client):

    login_as_SRO_client(client)
    response = client.post('/change-IBM-credentials')
    assert response.status_code == 401 
    logout_portal(client)

    login_as_admin_client(client)
    # Insertion (first time)
    response = client.post('/change-IBM-credentials', json={
        'new_apiKey': 'newKey',
        'new_serviceURL': 'newURL'
    })
    assert response.status_code == 200
    # Update creds
    response = client.post('/change-IBM-credentials', json={
        'new_apiKey': 'newKey',
        'new_serviceURL': 'newURL'
    })
    assert response.status_code == 200
    creds = IBMCred.query.first()
    assert creds.apiKey == 'newKey'
    assert creds.serviceURL == 'newURL'

    logout_portal(client)

