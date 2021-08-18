# Add project root to path
from pathlib import Path
import sys
root_path = Path(__file__).parents[1]
sys.path.insert(0, str(root_path))

# Imports
from MobileV.models import *
import pytest


@pytest.fixture(scope='module')
def new_admin():
    admin = Admin(username='testUsername', password='testPassword')
    return admin

