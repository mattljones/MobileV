### Functional tests for routes_auth.py

from conftest import login_portal_as_admin, login_portal_as_SRO, logout_portal


## TESTING PAGE LOADING -------------------------------------------------------

def test_login_page(client):
    response = client.get('/login')
    assert response.status_code == 200


def test_forgot_password_page(client):
    response = client.get('/forgot-password')
    assert response.status_code == 200


def test_reset_password_page(client):
    response = client.get('/reset-password')
    assert response.status_code == 404  # No token passed


## TESTING HTTP REQUESTS-------------------------------------------------------

def test_login_portal(client):
    response =  login_portal_as_admin(client)
    assert b'unsuccessful' not in response.data

    response =  login_portal_as_SRO(client)
    assert b'unsuccessful' not in response.data


def test_logout_portal(client):
    response = logout_portal(client)
    assert response.status_code == 200

