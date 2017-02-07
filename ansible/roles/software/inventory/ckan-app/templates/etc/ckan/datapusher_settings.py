import uuid

DEBUG = False
TESTING = False
SECRET_KEY = str(uuid.uuid4())
USERNAME = str(uuid.uuid4())
PASSWORD = str(uuid.uuid4())

NAME = 'datapusher'

# upload limit
MAX_CONTENT_LENGTH = 650000000

# database

db_user = "{{ inventory_db_user }}"
db_pass = "{{ inventory_db_pass }}"
db_server = "localhost"
db_database = "{{ inventory_datapusher_db_name }}"
SQLALCHEMY_DATABASE_URI = "postgresql://" + db_user + ":" + db_pass + "@" + db_server + "/" + db_database
# SQLALCHEMY_DATABASE_URI = 'sqlite:////tmp/job_store.db'

# webserver host and port

HOST = '0.0.0.0'
PORT = 8800

# logging

# FROM_EMAIL = 'server-error@example.com'
# ADMINS = ['yourname@example.com']  # where to send emails

# LOG_FILE = '/tmp/ckan_service.log'
STDERR = True
