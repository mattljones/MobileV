### Page classes implementing the Page Object Pattern

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from os import environ

# Load dummy account details from .env
from dotenv import load_dotenv
load_dotenv('.env')

base_url = 'http://127.0.0.1:5000'


class LoginPage:
    URL = base_url + '/login'
    USERNAME_INPUT = (By.ID, 'username')
    PASSWORD_INPUT = (By.ID, 'password')
    SRO_RADIO = (By.ID, 'SRO-radio-label')
    ERROR_MESSAGE = (By.ID, 'error-message')

    def __init__(self, browser):
        self.browser = browser
        self.admin_username = environ.get('TEST_ADMIN_USERNAME')
        self.admin_password = environ.get('TEST_ADMIN_PASSWORD')
        self.SRO_username = environ.get('TEST_SRO_USERNAME')
        self.SRO_password = environ.get('TEST_SRO_PASSWORD')

    def load(self):
        self.browser.get(LoginPage.URL)

    def login_admin(self, valid_credentials=True):
        username = self.admin_username if valid_credentials else 'invalid'
        username_input = self.browser.find_element(*LoginPage.USERNAME_INPUT)
        username_input.send_keys(username)
        password_input = self.browser.find_element(*LoginPage.PASSWORD_INPUT)
        password_input.send_keys(self.admin_password + Keys.RETURN)

    def login_SRO(self, valid_credentials=True):
        # Change user type to SRO first
        SRO_radio = self.browser.find_element(*LoginPage.SRO_RADIO)
        SRO_radio.click()
        username = self.SRO_username if valid_credentials else 'invalid'
        username_input = self.browser.find_element(*LoginPage.USERNAME_INPUT)
        username_input.send_keys(username)
        password_input = self.browser.find_element(*LoginPage.PASSWORD_INPUT)
        password_input.send_keys(self.SRO_password + Keys.RETURN)


class ForgotPasswordPage:
    URL = base_url + '/forgot-password'
    EMAIL_INPUT = (By.ID, 'email')
    SUCCESS_MESSAGE = (By.ID, 'success-message')

    def __init__(self, browser):
        self.browser = browser

    def load(self):
        self.browser.get(ForgotPasswordPage.URL)

    def submit_request(self):
        email_input = self.browser.find_element(*ForgotPasswordPage.EMAIL_INPUT)
        email_input.send_keys('test@gmail.com' + Keys.RETURN)


class AdminAppPage:
    URL = base_url + '/admin-accounts-app'
    NAVBAR_LOGOUT = (By.ID, 'navbar-logout')
    
    def __init__(self, browser):
        self.browser = browser

    def load(self):
        self.browser.get(AdminAppPage.URL)

    def logout(self):
        navbar_link = self.browser.find_element(*AdminAppPage.NAVBAR_LOGOUT)
        navbar_link.click()


class SRODashboardPage:
    URL = base_url + '/SRO-dashboard'
    NAVBAR_LOGOUT = (By.ID, 'navbar-logout')

    def __init__(self, browser):
        self.browser = browser

    def load(self):
        self.browser.get(SRODashboardPage.URL)

    def logout(self):
        sidebar_link = self.browser.find_element(*SRODashboardPage.NAVBAR_LOGOUT)
        sidebar_link.click()

