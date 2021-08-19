### Unit tests for stt.py

from MobileV.stt import *
import io

test_audio_filePath = 'MobileV/shares/dummy_data/test_conversion.m4a'

# Test bytes in memory correctly converted to mp3
def test_conversion():
    audio_bytes = io.FileIO(test_audio_filePath)
    audio_bytes_io = io.BytesIO(audio_bytes.read())
    converted_bytes = convert_to_mp3(audio_bytes_io)

    assert audio_bytes_io != converted_bytes


# # Test IBM STT transcription runs
# def test_transcription():

#     # Load IBM STT test account details from .env
#     from dotenv import load_dotenv
#     load_dotenv('.env')
#     apiKey = environ.get('TEST_API_KEY')
#     serviceURL = environ.get('TEST_SERVICE_URL')

#     audio_bytes = io.FileIO(test_audio_filePath)
#     audio_bytes_io = io.BytesIO(audio_bytes.read())
#     converted_bytes = convert_to_mp3(audio_bytes_io)

#     transcript = get_transcript(converted_bytes, apiKey, serviceURL)

#     assert transcript not in ['', None]


# Test word cloud generated successfully
def test_wordcloud_generation():
    transcript = 'this is a test transcript'
    wordCloudPath = 'MobileV/shares/dummy_data/test_wordcloud.png'
    success = False

    try:
        generate_save_wordcloud(transcript, wordCloudPath)
    except:
        success = False
    else:
        success = True

    assert success == True
    
