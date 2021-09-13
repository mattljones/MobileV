# MobileV

## Introduction
MobileV is designed to enable individuals to efficiently share voice recordings, and other scoring data, with their healthcare provider, as well as to receive analysis on their recordings in real time. 

The system combines a cross-platform mobile app, developed with Flutter, a web portal built on standard web technologies, Bootstrap and jQuery, and a Flask back-end.

## Folder structure
The ```FlaskApp``` folder contains the code for the Flask back-end and web portal, structured according to the [application factory pattern](https://flask.palletsprojects.com/en/2.0.x/patterns/appfactories/). ```requirements.txt``` contains the Python virtual environment dependencies. 

The ```MobileApp/mobilev``` folder contains the Flutter app code. The key folders therein are ```lib/```, for the core app code files, and ```tests/```, for unit and widget tests. ```pubspec.yaml``` contains the core app metadata and dependencies. 

## Flask app configuration
The Flask app can be run in three configurations: *production* (on-server, default), *development* (local development, remote database access) and *test* (for automated tests, local SQLite database).

The exact settings for each configuration can be found in ```FlaskApp/config.py```, which is selected at runtime through a command line argument:

- ```python wsgi.py prod```
- ```python wsgi.py dev```
- ```python wsgi.py test```

Note that this repository does not contain the following two files/folders required to run the app, *including for testing*, since they contain sensitive information:

- ```.env```
- ```FlaskApp/MobileV/dummy_data```

These will be provided as and when appropriate. 

## Flutter app binary creation
Assuming Flutter and Android Studio or Xcode is installed, an .apk or .ipa file can be created by running, in the ```MobileApp/mobilev``` directory:

- ```flutter clean```
- ```flutter build apk``` *or* ```flutter build ipa```

## Testing

### Flask app
54 Flask unit and functional tests are included, written with *pytest*. From within the virtual environment, and inside ```FlaskApp/```, run:

- ```pytest tests/flask_unit tests/flask_functional -v –-cov=MobileV```

### Web portal
19 browser automation (Selenium WebDriver) tests are included, written with *pytest*. From within the virtual environment, and inside ```FlaskApp/```, first run the Flask app in the *test* configuration, then execute the tests as before:

- ```python wsgi.py test```
- ```pytest tests/portal_functional -v```

### Flutter app
33 Flutter unit and widget tests are included, written with *flutter_test*. From within the ```MobileApp/mobilev``` directory, run:

- ```flutter test```

To generate a coverage report, use the *code_coverage* library as follows:

- ```dart pub global activate code_coverage```
- ```dart pub global run code_coverage```

## Known Issues
None.