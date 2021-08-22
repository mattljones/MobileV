### Selenium tests for logged-in Admin pages

from tests.conftest import login_as_admin_browser
from tests.portal_functional.pages import *
from selenium.webdriver.support.ui import WebDriverWait


# Test app user datatable loaded correctly
def test_admin_app_datatable(browser):
    login_as_admin_browser(browser)
    admin_app_page = AdminAppPage(browser)
    WebDriverWait(browser, 10).until(admin_app_page.check_for_datatable())


# Test app user account creation
def test_add_app_account(browser):
    login_as_admin_browser(browser)
    admin_app_page = AdminAppPage(browser)
    admin_app_page.open_add_modal()
    admin_app_page.submit_add_modal()
    WebDriverWait(browser, 10).until(admin_app_page.check_account_added())


# Test app user account modification
def test_edit_app_account(browser):
    login_as_admin_browser(browser)
    admin_app_page = AdminAppPage(browser)
    admin_app_page.open_edit_modal()
    admin_app_page.submit_edit_modal()
    WebDriverWait(browser, 10).until(admin_app_page.check_account_edited())


# Test app user account deletion
def test_delete_app_account(browser):
    login_as_admin_browser(browser)
    admin_app_page = AdminAppPage(browser)
    admin_app_page.open_delete_modal()
    admin_app_page.submit_delete_modal()
    WebDriverWait(browser, 10).until(admin_app_page.check_account_deleted())


# Test SRO datatable loaded correctly
def test_admin_SRO_datatable(browser):
    login_as_admin_browser(browser)
    admin_SRO_page = AdminSROPage(browser)
    admin_SRO_page.load()
    WebDriverWait(browser, 10).until(admin_SRO_page.check_for_datatable())


# Test SRO account creation
def test_add_SRO_account(browser):
    login_as_admin_browser(browser)
    admin_SRO_page = AdminSROPage(browser)
    admin_SRO_page.load()
    admin_SRO_page.open_add_modal()
    admin_SRO_page.submit_add_modal()
    WebDriverWait(browser, 10).until(admin_SRO_page.check_account_added())


# Test SRO account modification
def test_edit_SRO_account(browser):
    login_as_admin_browser(browser)
    admin_SRO_page = AdminSROPage(browser)
    admin_SRO_page.load()
    admin_SRO_page.open_edit_modal()
    admin_SRO_page.submit_edit_modal()
    WebDriverWait(browser, 10).until(admin_SRO_page.check_account_edited())


# Test SRO account deletion
def test_delete_SRO_account(browser):
    login_as_admin_browser(browser)
    admin_SRO_page = AdminSROPage(browser)
    admin_SRO_page.load()
    admin_SRO_page.open_delete_modal()
    admin_SRO_page.submit_delete_modal()
    WebDriverWait(browser, 10).until(admin_SRO_page.check_account_deleted())


# Test changing IBM credentials
def test_change_IBM_credentials(browser):
    login_as_admin_browser(browser)
    change_IBM_page = ChangeIBMPage(browser)
    change_IBM_page.load()
    change_IBM_page.change_credentials()
    WebDriverWait(browser, 10).until(change_IBM_page.check_updated())


# Test changing admin password
def test_admin_change_password(browser):

    login_as_admin_browser(browser)
    change_pass_page = AdminChangePassPage(browser)
    change_pass_page.load()

    # Check unsuccessful with invalid credentials
    change_pass_page.change_credentials(valid_credentials=False)
    WebDriverWait(browser, 10).until(change_pass_page.check_password_was_invalid())

    # Check successful with valid credentials
    change_pass_page.change_credentials()
    WebDriverWait(browser, 10).until(change_pass_page.check_password_changed())

