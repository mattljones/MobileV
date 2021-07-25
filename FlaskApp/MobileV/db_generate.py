# This file is adapted from code written for my COMP0067 group project

### DATABASE MANAGEMENT SCRIPTS
# - Create tables
# - Drop tables (but not database)
# - Seed tables with dummy data

# Modify python path for correct imports
import os, sys, csv
from pathlib import Path
main_dir = Path(os.path.abspath(__file__)).parents[1]
sys.path.insert(0, str(main_dir))

# Import application factory and db instance 
from MobileV import create_app
from MobileV.models import *


if __name__ == "__main__":

    try: 
        # Collect CLI arguments
        choice = sys.argv[1]
        env = sys.argv[2]

        # Push application context
        app = create_app(env)
        app.app_context().push()

        # CREATE all database tables (assumes database already created)
        if choice == 'create':
            db.create_all()
            print("Database tables created successfully!")

        # DROP all database tables (without dropping database)
        elif choice == 'drop':
            db.drop_all()
            print("Database tables deleted successfully.")

        # SEED the database with dummy data
        elif choice == 'seed':
            
            # Dummy data only provided for these four tables
            tables = ["Admin", "SRO", "AppUser", "Score", "Share"]

            for table in tables:

                with open('dummy_data/{}.csv'.format(table), newline="") as csv_file:

                    csv_reader = csv.reader(csv_file, delimiter=",")
                    headers = next(csv_reader)
                    objects = []

                    for row in csv_reader:
                        kwargs = str(dict(zip(headers, row)))
                        objects.append(eval(table + "(**" + kwargs + ")"))

                    db.session.bulk_save_objects(objects)
                    db.session.commit()

            print("Database seeded with dummy data successfully!")

        else: 
            raise Exception

    except Exception as e: 
        print(e)

