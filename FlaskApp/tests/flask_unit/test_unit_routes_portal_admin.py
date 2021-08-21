### Unit tests for routes_portal_admin.py

from MobileV.routes_portal_admin import get_new_password


# Check automatically generated passwords are sufficiently strong
def test_get_new_password():
    strong_password = get_new_password()
    contains_uppercase = False
    contains_lowercase = False
    contains_number = False
    
    for letter in strong_password:
        if letter.isupper():
            contains_uppercase = True
        elif letter.islower():
            contains_lowercase = True
        elif letter.isnumeric():
            contains_number = True

    assert contains_uppercase
    assert contains_lowercase
    assert contains_number
    assert len(strong_password) >= 6
    
