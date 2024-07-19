import os
import boto3
from dotenv import load_dotenv

load_dotenv()

AWS_S3_BUCKET = os.getenv("AWS_S3_BUCKET_METRICS")
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID_METRICS")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY_METRICS")

s3_client = boto3.client(
    "s3",
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
)


def put_data_to_s3(file_name, csv_data):
    response = s3_client.put_object(Bucket=AWS_S3_BUCKET, Key=file_name, Body=csv_data)

    status = response.get("ResponseMetadata", {}).get("HTTPStatusCode")

    if status == 200:
        print(f"Successful S3 put_object {file_name} response. Status - {status}")
    else:
        print(f"Unsuccessful S3 put_object {file_name} response. Status - {status}")
