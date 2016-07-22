from ConfigParser import SafeConfigParser
import logging
import os
import sys

import psycopg2

logging.basicConfig(format='%(message)s', level=logging.INFO)

LOGGER = logging.getLogger(__name__)


def _load_config(file_path):
    """load pycsw configuration"""
    abs_path = os.path.abspath(file_path)
    if not os.path.exists(abs_path):
        msg = 'pycsw config file {0} does not exist.'.format(abs_path)
        LOGGER.error(msg)
        raise AssertionError(msg)

    scp = SafeConfigParser()
    LOGGER.info('reading {0}'.format(file_path))
    scp.read(abs_path)

    return scp


def _parse_db_connection_string(db_conn_str):
    """parse sqlalchemy db connection string"""

    LOGGER.debug('parsing SQLAlchemy db connection string')
    conn = db_conn_str.split('://')[1]
    conn2 = conn.split('@')
    username, password = conn2[0].split(':')
    host, dbname = conn2[1].split('/')
    port = '5432'
    if host.count(':') == 1:
        host, port = host.split(':')

    return {
        'host': host,
        'port': port,
        'dbname': dbname,
        'username': username,
        'password': password
    }

if len(sys.argv) < 3:
    print 'Usage: %s <vacuumdb|reindex_fts> /path/to/pycsw.cfg' % sys.argv[0]
    sys.exit(1)

if sys.argv[1] not in ['vacuumdb', 'reindex_fts']:
    print 'ERROR: Invalid command.  vacuumdb or reindex_fts required'
    sys.exit(2)

CMD = sys.argv[1]
CONFIG = _load_config(sys.argv[2])
DBC = _parse_db_connection_string(CONFIG.get('repository', 'database'))

try:
    LOGGER.info('Connecting to database')
    CONN_STR = "host='{0}' port='{1}' dbname='{2}' user='{3}' password='{4}'".format(
        DBC['host'], DBC['port'], DBC['dbname'], DBC['username'], DBC['password'])
    CONN = psycopg2.connect(CONN_STR)
except Exception, err:
    raise AssertionError('Cannot connect to database: %s' % err)

CURSOR = CONN.cursor()

if CMD == 'vacuumdb':
    try:
        LOGGER.info('Running vacuum')
        old_isolation_level = CONN.isolation_level
        CONN.set_isolation_level(0)
        query = "VACUUM"
        CURSOR.execute(query)
        CONN.commit()
        CONN.set_isolation_level(old_isolation_level)
    except Exception, err:
        LOGGER.error(err)
        raise

elif CMD == 'reindex_fts':
    try:
        LOGGER.info('Dropping FTS index')
        CURSOR.execute('drop index fts_gin_idx')
        LOGGER.info('Creating FTS index')
        CURSOR.execute(
            'create index fts_gin_idx on records using gin(anytext_tsvector)')
    except Exception, err:
        LOGGER.error(err)
        raise
