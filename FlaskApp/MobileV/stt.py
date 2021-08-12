### FUNCTIONS RELATED TO HANDLING THE IBM SPEECH-TO-TEXT WEBSOCKET
# - Calling API to get transcript
# - Converting audio file to .mp3 format

from ibm_watson import SpeechToTextV1
from ibm_watson.websocket import RecognizeCallback, AudioSource
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from pydub import AudioSegment
import io
   

## CONVERSION TO MP3 ----------------------------------------------------------

def convert_to_mp3(temp_file):

    converted_file = io.BytesIO()
    AudioSegment.from_file(temp_file).export(converted_file, format="mp3")

    return converted_file


## IBM STT TRANSCRIPTION-------------------------------------------------------

class MyRecognizeCallback(RecognizeCallback):

    def __init__(self, transcript=''):
        RecognizeCallback.__init__(self)
        self.transcript = transcript

    def on_data(self, data):
        transcript = ''
        for result in data['results']:
            segment = result['alternatives'][0]['transcript']
            new_segment = segment.replace('%HESITATION ', '')
            transcript += new_segment

        self.transcript = transcript

    def on_error(self, error):
        print('Error received: {}'.format(error))

    def on_inactivity_timeout(self, error):
        print('Inactivity timeout: {}'.format(error))


def get_transcript(temp_file, apiKey, serviceURL):

    authenticator = IAMAuthenticator(apiKey)
    speech_to_text = SpeechToTextV1(authenticator=authenticator)
    speech_to_text.set_service_url(serviceURL)
    speech_to_text.set_default_headers(
        {'x-watson-learning-opt-out': 'true', 
         'x-watson-metadata': 'customer_id=customer'})

    myRecognizeCallback = MyRecognizeCallback()

    with temp_file as audio:
        audio_source = AudioSource(audio)
        speech_to_text.recognize_using_websocket(
            audio=audio_source,
            content_type='audio/mp3',
            recognize_callback=myRecognizeCallback,
            model='en-GB_NarrowbandModel')

    speech_to_text.delete_user_data('customer')

    return myRecognizeCallback.transcript


## GENERATE WORDCLOUD ---------------------------------------------------------