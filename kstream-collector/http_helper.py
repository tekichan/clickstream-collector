import json
import logging

# Retrieve client_id and check Authorization
# Headers object is assured by ALB Listener Rule
def get_client_id(event):
    try:
        headers = event['headers']
        client_id = headers['client_id'] if 'client_id' in headers else None

        # If client_id does not exist, then it is invalid
        if client_id is None:
            logging.error('Invalid client_id')
            return None

        authorization_val = headers['authorization'] if 'authorization' in headers else headers['Authorization'] if 'Authorization' in headers else None
        bearer, _, jwt_string = authorization_val.partition(' ')

        # Return Client ID when Authorization exists
        if jwt_string is not None:
            return client_id
    except:
        logging.exception('Error in processing client_id or authorization.')
        return None

# Generic return response
def get_http_response(status_code, status_desc, body_content, extended_headers=None):
    headers = {
            "Content-Type": "application/json"
            , "Access-Control-Allow-Origin": r'*'
            , "Access-Control-Allow-Credentials" : "true"
            , 'Access-Control-Allow-Headers': r'Content-Type,Cache-Control,Authorization,client_id'
            , 'Access-Control-Allow-Methods': r'OPTIONS,POST'
    }
    if extended_headers is not None:
        headers.update(extended_headers)
    return {
        'statusCode': status_code
        , 'statusDescription': status_desc
        , 'isBase64Encoded': False
        , "headers": headers
        , 'body': body_content
    }

# HTTP Response Internal Server Error
def response_internal_error(
    body_object={"response_code":"500", "message": "Internal Server Error"}
    ):
    return get_http_response(
        500
        , '500 Internal Server Error'
        , json.dumps(body_object)
    )    

# HTTP Response Unauthorized
def response_unauthorized(
    body_object={"response_code":"401", "message": "Invalid authorization"}
    ):
    return get_http_response(
        401
        , '401 Unauthorized'
        , json.dumps(body_object)
    )

# HTTP Reponse OK
def response_ok(body_object, extended_headers=None):
    return get_http_response(
        200
        , '200 OK'
        , json.dumps(body_object)
        , extended_headers
    )

# Whether it is an option request
def is_options(event):
    if event is not None and \
        'httpMethod' in event and \
        event['httpMethod'].upper() == 'OPTIONS':
        return True
    else:
        return False

# Response for OPTIONS
def response_options(headers=None):
    if headers is not None:
        return response_ok(
            None
            , {
                "Access-Control-Allow-Origin": headers['origin'] if 'origin' in headers else r'*'
                , "Access-Control-Allow-Credentials" : "true"
                , 'Access-Control-Allow-Headers': headers['access-control-request-headers'] if 'access-control-request-headers' in headers else r'Content-Type,Cache-Control,Authorization,client_id'
                , 'Access-Control-Allow-Methods': headers['access-control-request-method'] if 'access-control-request-method' in headers else r'OPTIONS,POST'
            }
        )
    else:
        return response_ok(None)