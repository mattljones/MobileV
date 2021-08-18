### Functional tests for routes_portal_admin.py

from conftest import login_portal_as_admin, login_portal_as_SRO, logout_portal
from MobileV.models import *


## TESTING PAGE LOADING -------------------------------------------------------

def test_app_accounts_page(client):

    login_portal_as_admin(client)
    response = client.get('/admin-accounts-app')
    assert response.status_code == 200
    logout_portal(client)

    login_portal_as_SRO(client)
    response = client.get('/admin-accounts-app')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


def test_SRO_accounts_page(client):

    login_portal_as_admin(client)
    response = client.get('/admin-accounts-SRO')
    assert response.status_code == 200
    logout_portal(client)

    login_portal_as_SRO(client)
    response = client.get('/admin-accounts-SRO')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


def test_change_IBM_page(client):

    login_portal_as_admin(client)
    response = client.get('/admin-change-IBM')
    assert response.status_code == 200
    logout_portal(client)

    login_portal_as_SRO(client)
    response = client.get('/admin-change-IBM')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


def test_admin_change_password_page(client):

    login_portal_as_admin(client)
    response = client.get('/admin-change-password')
    assert response.status_code == 200
    logout_portal(client)

    login_portal_as_SRO(client)
    response = client.get('/admin-change-password')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)

