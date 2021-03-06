### Functional tests for routes_auth.py

from flask import json
from conftest import login_as_admin_client, login_as_SRO_client, login_app, logout_portal
from MobileV.models import *
from os import environ


## TESTING PAGE LOADING -------------------------------------------------------

def test_login_page(client):

    # Not logged in
    response = client.get('/login')
    assert response.status_code == 200

    # Logged in as Admin
    login_as_admin_client(client)
    response = client.get('/login')
    assert response.status_code == 302
    logout_portal(client)

    # Logged in as SRO
    login_as_SRO_client(client)
    response = client.get('/login')
    assert response.status_code == 302
    logout_portal(client)


def test_forgot_password_page(client):

    # Not logged in
    response = client.get('/forgot-password')
    assert response.status_code == 200

    # Logged in as Admin
    login_as_admin_client(client)
    response = client.get('/forgot-password')
    assert response.status_code == 302
    logout_portal(client)

    # Logged in as SRO
    login_as_SRO_client(client)
    response = client.get('/forgot-password')
    assert response.status_code == 302
    logout_portal(client)


def test_reset_password_page(client):

    # Logged in as Admin
    login_as_admin_client(client)
    response = client.get('/reset-password/Admin/1')
    assert response.status_code == 302
    logout_portal(client)

    # Logged in as SRO
    login_as_SRO_client(client)
    response = client.get('/reset-password/SRO/1')
    assert response.status_code == 302
    logout_portal(client)

    # No token passed
    response = client.get('/reset-password')
    assert response.status_code == 404 

    # Invalid token passed
    response = client.get('/reset-password/SRO/1')
    assert response.status_code == 200 


## TESTING HTTP REQUESTS-------------------------------------------------------

def test_login_portal(client):
    response = login_as_admin_client(client)
    assert b'unsuccessful' not in response.data

    response = login_as_admin_client(client, fail=True)
    assert b'unsuccessful' in response.data

    response = login_as_SRO_client(client)
    assert b'unsuccessful' not in response.data

    response = login_as_SRO_client(client, fail=True)
    assert b'unsuccessful' in response.data


def test_login_app(client):
    response =  login_app(client)
    data = json.loads(response.data)
    assert data['authenticated'] == 'True'

    response =  login_app(client, fail=True)
    data = json.loads(response.data)
    assert data['authenticated'] == 'False'


def test_refresh_jwt(client):
    # Collect refresh token from login
    response = login_app(client)
    data = json.loads(response.data)
    access_token = data['accessToken']
    refresh_token = data['refreshToken']

    # Submit refresh token in header
    headers = {'Authorization': 'Bearer {}'.format(refresh_token)}
    refresh_response = client.post('/refresh-jwt', headers=headers)
    refresh_data = json.loads(refresh_response.data)
    refreshed_access_token = refresh_data['accessToken']

    assert response.status_code == 200
    assert access_token != refreshed_access_token


def test_logout_portal(client):
    response =  login_as_admin_client(client)
    assert response.status_code == 200


def test_change_password(client):

    # Load dummy account details from .env
    from dotenv import load_dotenv
    load_dotenv('.env')

    # App, password reset without valid token
    response = client.post('/change-password/app/123', json={
        'old_password': environ.get('TEST_APP_PASSWORD'),
        'new_password': environ.get('TEST_APP_PASSWORD')
    })
    assert b'unsuccessful' in response.data  

    # SRO, password reset without valid token
    response = client.post('/change-password/SRO/123', json={
        'old_password': environ.get('TEST_SRO_PASSWORD'),
        'new_password': environ.get('TEST_SRO_PASSWORD')
    })
    assert b'unsuccessful' in response.data  

    # Admin, invalid new password
    login_as_admin_client(client)
    response = client.post('/change-password', json={
        'old_password': environ.get('TEST_ADMIN_PASSWORD'),
        'new_password': ''
    })
    assert b'new_password_invalid' in response.data
    logout_portal(client)

    # SRO, incorrect old password
    login_as_SRO_client(client)
    response = client.post('/change-password', json={
        'old_password': 'incorrectPassword',
        'new_password': environ.get('TEST_SRO_PASSWORD')
    })
    assert b'wrong_password' in response.data
    logout_portal(client)

    # Admin, correct old password
    login_as_admin_client(client)
    response = client.post('/change-password', json={
        'old_password': environ.get('TEST_ADMIN_PASSWORD'),
        'new_password': 'newPassword'
    })
    assert b'successful' in response.data
    admin = Admin.query.filter(Admin.username == environ.get('TEST_ADMIN_USERNAME')).first()
    assert admin.check_password('newPassword') == True
    admin.change_password(environ.get('TEST_ADMIN_PASSWORD'))  # Revert password

    logout_portal(client)


def test_change_password_app(client):

    # Collect access token from login
    response = login_app(client)
    data = json.loads(response.data)
    access_token = data['accessToken']

    # Incorrect old password
    headers = {'Authorization': 'Bearer {}'.format(access_token)}
    response = client.post('/change-password/app', headers=headers, json={
        'old_password': 'incorrectPassword',
        'new_password': environ.get('TEST_APP_PASSWORD')
    })
    assert b'wrong_password' in response.data

    # Correct old password
    headers = {'Authorization': 'Bearer {}'.format(access_token)}
    response = client.post('/change-password/app', headers=headers, json={
        'old_password': environ.get('TEST_APP_PASSWORD'),
        'new_password': 'newPassword'
    })
    assert b'successful' in response.data
    user = AppUser.query.filter(AppUser.username == environ.get('TEST_APP_USERNAME')).first()
    assert user.check_password('newPassword') == True
    user.change_password(environ.get('TEST_APP_PASSWORD'))  # Revert password


def test_reset_password_request(client):

    # Correct SRO email
    response = client.post('/reset-password-request/SRO', json={
        'email': environ.get('TEST_SRO_EMAIL')
    })
    assert response.status_code == 200

    # Incorrect SRO email
    response = client.post('/reset-password-request/SRO', json={
        'email': 'incorrectEmail'
    })
    assert response.status_code == 200

    # Correct AppUser email
    response = client.post('/reset-password-request/app', json={
        'email': environ.get('TEST_APP_EMAIL')
    })
    assert response.status_code == 200

    # Incorrect AppUser email
    response = client.post('/reset-password-request/app', json={
        'email': environ.get('incorrectEmail')
    })
    assert response.status_code == 200

