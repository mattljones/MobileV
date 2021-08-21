### Functional tests for routes_portal_SRO.py

from conftest import login_as_admin_client, login_as_SRO_client, logout_portal
from MobileV.models import *


## TESTING PAGE LOADING -------------------------------------------------------

def test_SRO_dashboard_page(client):

    login_as_SRO_client(client)
    response = client.get('/SRO-dashboard')
    assert response.status_code == 200
    logout_portal(client)

    login_as_admin_client(client)
    response = client.get('/SRO-dashboard')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


def test_SRO_change_password_page(client):

    login_as_SRO_client(client)
    response = client.get('/SRO-change-password')
    assert response.status_code == 200
    logout_portal(client)

    login_as_admin_client(client)
    response = client.get('/SRO-change-password')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)
    

## TESTING AJAX REQUESTS-------------------------------------------------------

def test_get_SRO_app_users(client):
    
    login_as_admin_client(client)
    response = client.get('/get-SRO-app-users')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/get-SRO-app-users')
    assert response.status_code == 200
    logout_portal(client)


def test_get_app_user_scores(client):
    
    login_as_admin_client(client)
    response = client.get('/get-app-user-scores/1')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/get-app-user-scores/1')
    assert response.status_code == 200
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/get-app-user-scores/2')
    assert response.status_code == 302  # Not the SRO's own app user
    logout_portal(client)


def test_update_app_user_scores(client):

    login_as_admin_client(client)
    response = client.post('/update-app-user-scores/1')
    assert response.status_code == 401
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.post('/update-app-user-scores/2')
    assert response.status_code == 401  # Not the SRO's own app user
    logout_portal(client) 

    login_as_SRO_client(client)
    response = client.post('/update-app-user-scores/1', json={
        'inserted': [],
        'updated': {},
        'deleted': []
    })
    assert response.status_code == 200
    logout_portal(client)


def test_get_app_user_shares(client):
    
    login_as_admin_client(client)
    response = client.get('/get-app-user-shares/1')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/get-app-user-shares/1')
    assert response.status_code == 200
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/get-app-user-shares/2')
    assert response.status_code == 302  # Not the SRO's own app user
    logout_portal(client)


def test_download_app_user_share(client):
    
    login_as_admin_client(client)
    response = client.get('/download-app-user-share/1')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.get('/download-app-user-share/1')
    assert response.status_code == 200
    logout_portal(client)


def test_delete_app_user_share(client):
    
    login_as_admin_client(client)
    response = client.post('/delete-app-user-share')
    assert response.status_code == 401 
    logout_portal(client)

    login_as_SRO_client(client)
    response = client.post('/delete-app-user-share', json={
        'shareID': 2
    })
    assert response.status_code == 200

    logout_portal(client)

