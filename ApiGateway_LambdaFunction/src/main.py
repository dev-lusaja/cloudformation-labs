import json

def run(event, context):
    return {
        'code': 200,
        'message': json.dumps('hello world')
        }