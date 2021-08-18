### Functional tests for routes_portal_SRO.py

from conftest import login_portal_as_admin, login_portal_as_SRO, logout_portal
from MobileV.models import *


## TESTING PAGE LOADING -------------------------------------------------------

def test_SRO_dashboard_page(client):

    login_portal_as_SRO(client)
    response = client.get('/SRO-dashboard')
    assert response.status_code == 200
    logout_portal(client)

    login_portal_as_admin(client)
    response = client.get('/SRO-dashboard')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)


def test_SRO_change_password_page(client):

    login_portal_as_SRO(client)
    response = client.get('/SRO-change-password')
    assert response.status_code == 200
    logout_portal(client)

    login_portal_as_admin(client)
    response = client.get('/SRO-change-password')
    assert response.status_code == 302  # Should be redirected
    logout_portal(client)
    
