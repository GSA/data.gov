from StringIO import StringIO
import os
import sys

activate_this = os.path.join('/usr/lib/ckan/bin/activate_this.py')
execfile(activate_this, {'__file__': activate_this})

app_path = os.path.dirname(__file__)
sys.path.append(app_path)

from pycsw import server

def application(env, start_response):
    """WSGI wrapper"""
    
    config = env['PYCSW_CONFIG']

    if 'HTTP_HOST' in env and ':' in env['HTTP_HOST']:
        env['HTTP_HOST'] = env['HTTP_HOST'].split(':')[0]

    env['local.app_root'] = app_path

    csw = server.Csw(config, env)

    gzip = False
    if ('HTTP_ACCEPT_ENCODING' in env and
            env['HTTP_ACCEPT_ENCODING'].find('gzip') != -1):
        # set for gzip compressed response
        gzip = True

    # set compression level
    if csw.config.has_option('server', 'gzip_compresslevel'):
        gzip_compresslevel = \
            int(csw.config.get('server', 'gzip_compresslevel'))
    else:
        gzip_compresslevel = 0

    contents = csw.dispatch_wsgi()

    headers = {}

    if gzip and gzip_compresslevel > 0:
        import gzip

        buf = StringIO()
        gzipfile = gzip.GzipFile(mode='wb', fileobj=buf,
                                 compresslevel=gzip_compresslevel)
        gzipfile.write(contents)
        gzipfile.close()

        contents = buf.getvalue()

        headers['Content-Encoding'] = 'gzip'

    headers['Content-Length'] = str(len(contents))
    headers['Content-Type'] = csw.contenttype

    status = '200 OK'
    start_response(status, headers.items())

    return [contents]