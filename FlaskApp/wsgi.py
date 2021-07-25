### WSGI ENTRY POINT

# Change python path for correct imports
import os, sys
from pathlib import Path
main_dir = Path(os.path.abspath(__file__))
sys.path.insert(0, str(main_dir))

# Import application factory
from MobileV import create_app

# Default to 'prod' configuration if being run by Gunicorn
if len(sys.argv) > 2:
    env = 'prod'
else: 
    env = sys.argv[1]


app = create_app(env)

if app is not None and __name__ == "__main__":
    app.run()
