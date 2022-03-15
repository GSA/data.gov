#!/usr/bin/python

'''
    This script reads DB credetials from ckan production.ini file,
    It connects to the database with master user role,
    It assumes the database is blank.
    It creates necessary databases, roles, and set permissions
    And finally it runs 'ckan db init' to initialize the ckan db.

    Verified with CKAN 2.8/2.9 on AWS and local postgres db

    More discussion can be found here:
    https://github.com/gsa/data.gov/issues/2038
'''

import ConfigParser
import os
from subprocess import Popen, PIPE, STDOUT

CKAN_INI_FILE = '/etc/ckan/production.ini'

def check_sudo():
    '''
        make sure we have sudo access to
        read the produciton.ini file
    '''
    try:
        os.open(CKAN_INI_FILE, os.O_RDONLY)
    except OSError:
        exit("Error: You need sudo access.")

def get_ini(name):
    '''
        get db credentials from production.ini
    '''
    config = ConfigParser.RawConfigParser()
    config.read(CKAN_INI_FILE)

    return config.get('app:main', name)

def run(command, exit_on_error=True):
    process = Popen(command, stdout=PIPE, shell=True, stderr=STDOUT)
    while True:
        line = process.stdout.readline().rstrip()
        if not line:
            break
        process.wait()
        print line

    if process.returncode != 0:
        if exit_on_error:
            print "Halt on this error"
            exit(-1)
        else:
            print "Continue with this error"

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

    if db['datastore_server'].lower() == db['db_server'].lower():
    # We are using CKAN DB and Datastore DB are residing on the same DB server.
    # We assume db_user is the master user.
        print '\n## Creating CKAN database %s' % db['db_database']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE DATABASE %s ENCODING UTF8"' % (
            db['db_pass'], db['db_server'], db['db_user'], db['db_database']),
            False
        )

        print '\n## Creating Datastore write user %s' % db['datastore_user']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE USER %s WITH PASSWORD \'%s\' CREATEDB"' % (
            db['db_pass'], db['db_server'], db['db_user'], db['datastore_user'], db['datastore_pass'])
        )

        print '\n## Creating Datastore read user %s' % db['datastore_ro_user']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE USER %s WITH PASSWORD \'%s\'"' % (
            db['db_pass'], db['db_server'], db['db_user'], db['datastore_ro_user'], db['datastore_ro_pass']
        ))

        print '\n## Creating Datastore database %s' % db['datastore_database']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE DATABASE %s ENCODING UTF8"' % (
            db['datastore_pass'], db['db_server'], db['datastore_user'], db['datastore_database']
        ))

        print '\n## Set permissions for Datastore DB'
        run('sudo ckan datastore set-permissions | PGPASSWORD=%s psql -h %s -U %s -d %s --set ON_ERROR_STOP=1' % (
            db['datastore_pass'], db['db_server'], db['datastore_user'], db['datastore_database']
        ))

        # revert changes for AWS RDS privilege workaround
        print '\n## Change for Datastore DB owner to %s' % db['db_user']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "ALTER DATABASE %s OWNER TO %s"' % (
            db['db_pass'], db['db_server'], db['db_user'], db['datastore_database'], db['db_user']
        ))

        # revert changes for AWS RDS privilege workaround
        print '\n## Remove Createdb privilege from Datastore write user %s' % db['datastore_user']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "ALTER USER %s WITH NOCREATEDB"' % (
            db['db_pass'], db['db_server'], db['db_user'], db['datastore_user']
        ))

    else:
    # CKAN DB and Datastore DB are on different DB server hosts
    # We assume db_user is the CKAN DB master user, datastore_user is Datastore DB master user
        print '\n## Creating CKAN database %s' % db['db_database']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE DATABASE %s ENCODING UTF8"' % (
            db['db_pass'], db['db_server'], db['db_user'], db['db_database']),
            False
        )

        print '\n## Creating Datastore database %s' % db['datastore_database']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE DATABASE %s ENCODING UTF8"' % (
            db['datastore_pass'], db['datastore_server'], db['datastore_user'], db['datastore_database']),
            False
        )

        print '\n## Creating Datastore read user %s' % db['datastore_ro_user']
        run('PGPASSWORD=%s psql -h %s -U %s postgres -c "CREATE USER %s WITH PASSWORD \'%s\'"' % (
            db['datastore_pass'], db['datastore_server'], db['datastore_user'], db['datastore_ro_user'], db['datastore_ro_pass']
        ))

        print '\n## Set permissions for Datastore DB'
        run('sudo ckan datastore set-permissions | PGPASSWORD=%s psql -h %s -U %s -d %s' % (
            db['datastore_pass'], db['datastore_server'], db['datastore_user'], db['datastore_database']
        ))

    # Finally!
    print '\n## Initialize CKAN database'
    run('sudo ckan db init')

    print '\n## Done!'

if __name__ == '__main__':
    main()
