### ROUTES RELATED TO THE MOBILE APP

import MobileV.ibm_stt as ibm_stt
from MobileV.models import *
from flask import Blueprint, request, Response, copy_current_request_context
from threading import Thread
import io, gc

# Create blueprint for these routes
app_bp = Blueprint('app_bp', __name__)


@app_bp.route('/transcribe', methods=["POST"])
def transcribe():

    @copy_current_request_context
    def handover():

        temp_file = io.BytesIO(request.get_data())
        converted_file = ibm_stt.convert_to_mp3(temp_file)

        ibm_creds = IBMCred.query.first()
        ibm_stt.get_transcript(converted_file, ibm_creds.apiKey, ibm_creds.serviceURL)

        del temp_file
        del converted_file
        gc.collect()
        

    Thread(target=handover).start()

    return Response(status=200)

