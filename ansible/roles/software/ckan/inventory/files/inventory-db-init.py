#!/usr/bin/python

'''
    This script reads DB credetials from ckan production.ini file,
    It connects to the database with master user role,
    It assumes the database is blank.
    It creates necessary databases, roles, and set permissions
    And finally it runs 'ckan db init' to initialize the ckan db.

    Verified with CKAN 2.8 on AWS and local postgres db verison 9.5/9.6

    More discussion can be found here:
    https://github.com/GSA/datagov-deploy/issues/2038
'''

import ConfigParser
import os
from subprocess import Popen, PIPE, STDOUT

CKAN_INI_FILE = '/etc/ckan/production.ini'

def check_sudo():
    try:
        os.open(CKAN_INI_FILE, os.O_RDONLY)
    except OSError:
        exit("Error: You need sudo access.")

def get_ini(name):
    config = ConfigParser.RawConfigParser()
    config.read('/etc/ckan/production.ini')

    return config.get('app:main', name)

def run(command):
    process = Popen(command, stdout=PIPE, shell=True, stderr=STDOUT)
    while True:
        line = process.stdout.readline().rstrip()
        if not line:
            break
        process.wait()
        print line
    if process.returncode != 0:
        exit(-1)

def main():

    check_sudo()

    vars = [
      'db_user',
      'db_pass',
      'db_server',
      'db_database',
      'datastore_user',
      'datastore_pass',
      'datastore_ro_user',
      'datastore_ro_pass',
      'datastore_server',
      'datastore_database',
    ]

    db = {}
    for var in vars:
        db[var] = get_ini(var)

    print '\n## Creating CKAN database %s' % db['db_database']
    run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE DATABASE %s ENCODING UTF8"' % (
        db['db_pass'], db['db_server'], db['db_user'], db['db_database']
    ))

    print '\n## Creating Datastore write user %s' % db['datastore_user']
    run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE USER %s WITH PASSWORD \'%s\' CREATEDB"' % (
        db['db_pass'], db['db_server'], db['db_user'], db['datastore_user'], db['datastore_pass']
    ))

    print '\n## Creating Datastore read user %s' % db['datastore_ro_user']
    run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE USER %s WITH PASSWORD \'%s\'"' % (
        db['db_pass'], db['db_server'], db['db_user'], db['datastore_ro_user'], db['datastore_ro_pass']
    ))

    print '\n## Creating Datastore database %s' % db['datastore_database']
    run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE DATABASE %s ENCODING UTF8"' % (
        db['datastore_pass'], db['db_server'], db['datastore_user'], db['datastore_database']
    ))

    print '\n## Remove Createdb privilege from Datastore write user %s' % db['datastore_user']
    run('PGPASSWORD=%s psql -h %s -U %s postgres -c "ALTER USER %s WITH NOCREATEDB"' % (
        db['db_pass'], db['db_server'], db['db_user'], db['datastore_user']
    ))

    print '\n## Set permissions for Datastore DB'
    run('sudo ckan datastore set-permissions | PGPASSWORD=%s psql -h %s -U %s -d %s --set ON_ERROR_STOP=1' % (
        db['datastore_pass'], db['db_server'], db['datastore_user'], db['datastore_database']
    ))

    print '\n## Initialize CKAN database'
    run('sudo ckan db init')

    print '\n## Done!'

if __name__ == '__main__':
    main()
