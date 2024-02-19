from sutils.cprint import cprint

def lambda_handler(event, context):
    cprint(event)
    return event