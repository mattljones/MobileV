### Page classes implementing the Page Object Pattern

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from os import environ

# Load dummy account details from .env
from dotenv import load_dotenv
load_dotenv('.env')

base_url = 'http://127.0.0.1:5000'


## AUTHENTICATION PAGE CLASSES ------------------------------------------------

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


class ChangePassForm:
    CURRENT_INPUT = (By.ID, 'current-password')
    NEW_INPUT = (By.ID, 'new-password')
    CONFIRM_INPUT = (By.ID, 'confirm-password')
    ERROR_MESSAGE = (By.ID, 'error-message')
    SUCCESS_TOAST = (By.ID, 'success-toast')
    
    def __init__(self, browser):
        self.browser = browser

    def load(self):
        self.browser.get(self.URL)

    def change_credentials(self, valid_credentials=True):
        current = self.current_password if valid_credentials else 'invalid'
        current_input = self.browser.find_element(*ChangePassForm.CURRENT_INPUT)
        current_input.clear()
        current_input.send_keys(current)
        new_input = self.browser.find_element(*ChangePassForm.NEW_INPUT)
        new_input.clear()
        new_input.send_keys(self.current_password)
        confirm_input = self.browser.find_element(*ChangePassForm.CONFIRM_INPUT)
        confirm_input.clear()
        confirm_input.send_keys(self.current_password + Keys.RETURN)

    def check_password_was_invalid(self):
        def check_for_error_message(browser):
            if browser.find_element(*ChangePassForm.ERROR_MESSAGE).is_displayed():
                return True
            return False
        return check_for_error_message

    def check_password_changed(self):
        def check_for_success_toast(browser):
            if browser.find_element(*ChangePassForm.SUCCESS_TOAST).is_displayed():
                return True
            return False
        return check_for_success_toast


## ADMIN PAGE CLASSES ---------------------------------------------------------

class AdminAppPage:
    URL = base_url + '/admin-accounts-app'
    NAVBAR_LOGOUT = (By.ID, 'navbar-logout')
    
    def __init__(self, browser):
        self.browser = browser

    def load(self):
        self.browser.get(AdminAppPage.URL)

    def check_for_datatable(self):
        def check_for_tbody(browser):
            if len(browser.find_elements(By.TAG_NAME, 'tbody')) > 0:
                return True
            return False
        return check_for_tbody

    def logout(self):
        navbar_link = self.browser.find_element(*AdminAppPage.NAVBAR_LOGOUT)
        navbar_link.click()


class AdminSROPage:
    URL = base_url + '/admin-accounts-SRO'
    
    def __init__(self, browser):
        self.browser = browser

    def load(self):
        self.browser.get(AdminSROPage.URL)

    def check_for_datatable(self):
        def check_for_tbody(browser):
            if len(browser.find_elements(By.TAG_NAME, 'tbody')) > 0:
                return True
            return False
        return check_for_tbody


class ChangeIBMPage:
    URL = base_url + '/admin-change-IBM'
    API_KEY_TEXT = (By.ID, 'current-api-key')
    SERVICE_URL_TEXT = (By.ID, 'current-service-url')
    API_KEY_INPUT = (By.ID, 'new-api-key')
    SERVICE_URL_INPUT = (By.ID, 'new-service-url')
    TEST_API_KEY = 'test_key'
    TEST_SERVICE_URL = 'test_url'
    
    def __init__(self, browser):
        self.browser = browser

    def load(self):
        self.browser.get(ChangeIBMPage.URL)

    def change_credentials(self):
        api_key_input = self.browser.find_element(*ChangeIBMPage.API_KEY_INPUT)
        api_key_input.send_keys(ChangeIBMPage.TEST_API_KEY)
        service_url_input = self.browser.find_element(*ChangeIBMPage.SERVICE_URL_INPUT)
        service_url_input.send_keys(ChangeIBMPage.TEST_SERVICE_URL + Keys.RETURN)

    def check_updated(self):
        def check_for_text(browser):
            isApiKeyUpdated = browser.find_element(*ChangeIBMPage.API_KEY_TEXT).text == ChangeIBMPage.TEST_API_KEY
            isServiceURLUpdated = browser.find_element(*ChangeIBMPage.SERVICE_URL_TEXT).text == ChangeIBMPage.TEST_SERVICE_URL
            if isApiKeyUpdated and isServiceURLUpdated:
                return True
            return False
        return check_for_text


class AdminChangePassPage(ChangePassForm):
    URL = base_url + '/admin-change-password'

    def __init__(self, browser):
        ChangePassForm.__init__(self, browser)
        self.current_password = environ.get('TEST_ADMIN_PASSWORD')


## SRO PAGE CLASSES -----------------------------------------------------------

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

