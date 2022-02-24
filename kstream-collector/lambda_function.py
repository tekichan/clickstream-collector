import json
import logging
import os

import boto3

# Import local libraries
from http_helper import is_options, response_options, get_client_id, response_ok, response_internal_error, response_unauthorized

# Define Logging
LOGLEVEL = os.environ.get('LOG_LEVEL', 'WARNING').upper()
logging.basicConfig(level=logging.getLevelName(LOGLEVEL))

# Environment Variables
REGION_NAME = os.environ['REGION_NAME'] if 'REGION_NAME' in os.environ else 'eu-west-1'
KSTREAM_FIREHOSE = os.environ['KSTREAM_FIREHOSE'] if 'KSTREAM_FIREHOSE' in os.environ else 'firehose_to_s3_stream'

# Global Variables
session = boto3.session.Session()
firehose_client = session.client('firehose', region_name=REGION_NAME)

# Write Data to Firehose
def write_to_firehose(record_data):
    try:
        firehose_client.put_record(
            DeliveryStreamName=KSTREAM_FIREHOSE
            , Record={'Data': record_data}
        )
        return True
    except:
        logging.exception('Failed to write to Firehose.')
        return False

# Main function of Lambda function
def lambda_handler(event, context):
    try:
        # Quickly handle OPTIONS - CORS
        if is_options(event):
            return response_options()

        client_id = get_client_id(event)    # Get a valid Client ID by an authorized header

        if client_id is not None:
            # Prepare record data
            body_json = json.loads(event['body'])

            body_json['client_id'] = client_id  # Insert Client ID (business units) into record line

            # Insert Client IP (customers)
            if 'x-forwarded-for' in event['headers']:
                body_json['client_ip'] = event['headers']['x-forwarded-for']
            
            # Capture customer client app or device info
            if 'user-agent' in event['headers']:
                body_json['user_agent'] = event['headers']['user-agent']

            # Write to Firehose
            firehose_result = write_to_firehose(json.dumps(body_json))
            if firehose_result:
                return response_ok({"response_code":"200", "message": "Clickstream collected."})
            else:
                return response_internal_error({"response_code":"50001", "message": "Failed to collect data."})
        else:
            return response_unauthorized()
    except:
        logging.exception('Error in clickstream collection.')
        return response_internal_error()
