### Selenium tests for logged-in SRO pages

from tests.conftest import login_as_SRO_browser
from tests.portal_functional.pages import *
from selenium.webdriver.support.ui import WebDriverWait


# Test main datatable loaded correctly
def test_SRO_dashboard_datatable(browser):
    login_as_SRO_browser(browser)
    dashboard_page = SRODashboardPage(browser)
    WebDriverWait(browser, 10).until(dashboard_page.check_for_datatable())


# Test editing app user scores
def test_edit_user_scores(browser):
    login_as_SRO_browser(browser)
    dashboard_page = SRODashboardPage(browser)
    dashboard_page.open_scores_modal()
    dashboard_page.submit_scores_modal()
    dashboard_page.check_scores_updated()


# Test downloading user share
def test_download_user_share(browser):
    login_as_SRO_browser(browser)
    dashboard_page = SRODashboardPage(browser)
    dashboard_page.open_shares_modal()
    dashboard_page.download_share()


# Test changing SRO password
def test_SRO_change_password(browser):

    login_as_SRO_browser(browser)
    change_pass_page = SROChangePassPage(browser)
    change_pass_page.load()

    # Check unsuccessful with invalid credentials
    change_pass_page.change_credentials(valid_credentials=False)
    WebDriverWait(browser, 10).until(change_pass_page.check_password_was_invalid())

    # Check successful with valid credentials
    change_pass_page.change_credentials()
    WebDriverWait(browser, 10).until(change_pass_page.check_password_changed())

