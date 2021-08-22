### Selenium tests for login page (and logout after login)

from tests.conftest import login_as_SRO_browser, login_as_admin_browser
from tests.portal_functional.pages import *
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


# Test admin login with correct credentials (then logout)
def test_login_logout_as_admin(browser):

    # Login
    login_as_admin_browser(browser)
    WebDriverWait(browser, 10).until(EC.url_to_be(AdminAppPage.URL))

    # Logout
    admin_app_page = AdminAppPage(browser)
    admin_app_page.logout()
    WebDriverWait(browser, 10).until(EC.url_to_be(LoginPage.URL))


# Test admin login with incorrect credentials
def test_login_as_admin_invalid(browser):
    login_page = LoginPage(browser)
    login_page.load()
    login_page.login_admin(valid_credentials=False)
    WebDriverWait(browser, 10).until(EC.visibility_of_element_located(LoginPage.ERROR_MESSAGE))


# Test SRO login with correct credentials (then logout)
def test_login_logout_as_SRO(browser):

    # Login
    login_as_SRO_browser(browser)
    WebDriverWait(browser, 10).until(EC.url_to_be(SRODashboardPage.URL))

    # Logout 
    sro_dashboard_page = SRODashboardPage(browser)
    sro_dashboard_page.logout()
    WebDriverWait(browser, 10).until(EC.url_to_be(LoginPage.URL))


# Test SRO login with incorrect credentials
def test_login_as_SRO_invalid(browser):
    login_page = LoginPage(browser)
    login_page.load()
    login_page.login_SRO(valid_credentials=False)
    WebDriverWait(browser, 10).until(EC.visibility_of_element_located(LoginPage.ERROR_MESSAGE))
    

# Test submitting a password reset request
def test_reset_password_request(browser):
    forgot_password_page = ForgotPasswordPage(browser)
    forgot_password_page.load()
    forgot_password_page.submit_request()
    WebDriverWait(browser, 10).until(EC.visibility_of_element_located(ForgotPasswordPage.SUCCESS_MESSAGE))

