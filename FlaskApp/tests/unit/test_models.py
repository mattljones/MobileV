

# When a new Admin is created check fields defined correctly
def test_new_admin_with_fixture(new_admin):
    assert new_admin.username == 'testUsername'
    assert new_admin.check_password('testPassword') == False
    assert new_admin.get_role() == 'Admin'

