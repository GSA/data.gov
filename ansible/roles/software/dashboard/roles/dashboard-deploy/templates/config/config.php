<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

$root_dir = '{{ project_source_path }}';
require_once($root_dir . "/vendor/autoload.php");

/**
 * Use Dotenv to set required environment variables and load .env file in root
 */
if (file_exists($root_dir . '/.env')) {
    $dotenv = new \Dotenv\Dotenv($root_dir);
    $dotenv->load();
}

$config['download_dir'] = '{{ project_source_path }}/shared/downloads';
$config['archive_dir'] = '{{ project_source_path }}/shared/archive';
$config['docs_path'] = 'https://raw.githubusercontent.com/GSA/project-open-data-dashboard/master/documentation/';

$config['import_active'] = true;
$config['show_all_offices'] = false;
$config['max_remote_size'] = 5000000;

$config['google_analytics_id'] = ''; // UA-xxxxxxx-xx
$config['google_analytics_domain'] = ''; // domain.com

// Set local time zone 
date_default_timezone_set('America/New_York');

$config['tmp_csv_import'] = '{{ project_source_path }}/shared/downloads/import.csv';
$config['pre_approved_admins'] = explode(",", getenv('PRE_APPROVED_ADMINS'));


/*
|--------------------------------------------------------------------------
| Base Site URL
|--------------------------------------------------------------------------
|
| URL to your CodeIgniter root. Typically this will be your base URL,
| WITH a trailing slash:
|
|	http://example.com/
|
| If this is not set then CodeIgniter will guess the protocol, domain and
| path to your installation.
|
*/
$protocol = 'http';
if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off') {
    $protocol = 'https';
}

$default_host = 'labs.data.gov/dashboard';
if (isset($_SERVER['HTTP_HOST']) && $_SERVER['HTTP_HOST']) {
    $default_host = $_SERVER['HTTP_HOST'];
}

$config['base_url'] = $protocol . '://' . $default_host;
//$config['base_url'] = 'https://labs.data.gov/dashboard/';

/*
|--------------------------------------------------------------------------
| SAML Settings
|--------------------------------------------------------------------------
| https://max.gov/maxportal/home.action
|
| https://login.test.max.gov/idp/shibboleth
|
*/

$config['saml'] = array(
    // If 'strict' is True, then the PHP Toolkit will reject unsigned
    // or unencrypted messages if it expects them to be signed or encrypted.
    // Also it will reject the messages if the SAML standard is not strictly
    // followed: Destination, NameId, Conditions ... are validated too.
    'strict' => false,

    // Enable debug mode (to print errors).
    'debug' => true,

    // Service Provider Data that we are deploying.
    'sp' => array(
        // Identifier of the SP entity  (must be a URI)
        'entityId' => $config['base_url'] . '/saml/metadata',
        // Specifies info about where and how the <AuthnResponse> message MUST be
        // returned to the requester, in this case our SP.
        'assertionConsumerService' => array(
            // URL Location where the <Response> from the IdP will be returned
            'url' => $config['base_url'] . '/saml/acs',
            // SAML protocol binding to be used when returning the <Response>
            // message. OneLogin Toolkit supports this endpoint for the
            // HTTP-POST binding only.
            'binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
        ),
        // If you need to specify requested attributes, set a
        // attributeConsumingService. nameFormat, attributeValue and
        // friendlyName can be omitted
        "attributeConsumingService" => array(
            "ServiceName" => "SP test",
            "serviceDescription" => "Test Service",
            "requestedAttributes" => array(
                array(
                    "name" => "",
                    "isRequired" => false,
                    "nameFormat" => "",
                    "friendlyName" => "",
                    "attributeValue" => array()
                )
            )
        ),
        // Specifies info about where and how the <Logout Response> message MUST be
        // returned to the requester, in this case our SP.
        'singleLogoutService' => array(
            // URL Location where the <Response> from the IdP will be returned
            'url' => $config['base_url'] . '/saml/logout',
            // SAML protocol binding to be used when returning the <Response>
            // message. OneLogin Toolkit supports the HTTP-Redirect binding
            // only for this endpoint.
            'binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
        ),
        // Specifies the constraints on the name identifier to be used to
        // represent the requested subject.
        // Take a look on lib/Saml2/Constants.php to see the NameIdFormat supported.
        'NameIDFormat' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
        // Usually x509cert and privateKey of the SP are provided by files placed at
        // the certs folder. But we can also provide them with the following parameters
        'x509cert' => '-----BEGIN CERTIFICATE-----
                        MIICPjCCAaegAwIBAgIBADANBgkqhkiG9w0BAQ0FADA8MQswCQYDVQQGEwJ1czER
                        MA8GA1UECAwIVklSR0lOSUExDDAKBgNVBAoMA0dTQTEMMAoGA1UEAwwDR1NBMB4X
                        DTE2MTAxMDE5MDUyNloXDTE5MDcwNjE5MDUyNlowPDELMAkGA1UEBhMCdXMxETAP
                        BgNVBAgMCFZJUkdJTklBMQwwCgYDVQQKDANHU0ExDDAKBgNVBAMMA0dTQTCBnzAN
                        BgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAtD9Jqb92JQmNgvw5vYk2bMNacTIsogLM
                        EtT+Ym4EtLq7F/gUlr70CTF95lXWoaBDIjngbuIqyiScVzi4Jo9Sd2w3Wxh4Euxc
                        JzNVRNhgofQbq1sT2FrjBOekogcrwbF+V60wVVPa5Mhq0g9sWsxjt6YGl8xWO+MC
                        Vj6fWM844Q8CAwEAAaNQME4wHQYDVR0OBBYEFJnYOxv44mMlkFnam9/U0qtUFENY
                        MB8GA1UdIwQYMBaAFJnYOxv44mMlkFnam9/U0qtUFENYMAwGA1UdEwQFMAMBAf8w
                        DQYJKoZIhvcNAQENBQADgYEASkP1kSECk+koipcTrbu7pj9GYtZb9cGWDovrtniY
                        bHphRM6Ytex4XplQ1dqGNAfqVR383ArKTPF5m8JqrKGGklMeROme6Xs5EfSE+inM
                        4PVoQR3CK6tyAiwVeDmZIbrGoDOf+msBO/7zLorTtQwqr1j8b0Yvrx7StXayrH9a
                        2jY=
                        -----END CERTIFICATE-----',
        'privateKey' => '{{ saml_private_key }}',

    ),

    // Identity Provider Data that we want connected with our SP.
    'idp' => array(
        // Identifier of the IdP entity  (must be a URI)
        'entityId' => 'https://login.test.max.gov/idp/',
        // SSO endpoint info of the IdP. (Authentication Request protocol)
        'singleSignOnService' => array(
            // URL Target of the IdP where the Authentication Request Message
            // will be sent.
            'url' => 'https://login.test.max.gov/idp/profile/SAML2/POST-SimpleSign/SSO',
            // SAML protocol binding to be used when returning the <Response>
            // message. OneLogin Toolkit supports the HTTP-Redirect binding
            // only for this endpoint.
            'binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign',
        ),
        // SLO endpoint info of the IdP.
        'singleLogoutService' => array(
            // URL Location of the IdP where SLO Request will be sent.
            'url' => 'https://login.test.max.gov/idp/profile/SAML2/POST/SLO',
            // SAML protocol binding to be used when returning the <Response>
            // message. OneLogin Toolkit supports the HTTP-Redirect binding
            // only for this endpoint.
            'binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
        ),
        // Public x509 certificate of the IdP
        'x509cert' => 'MIIDMzCCAhugAwIBAgIUGZmNOfGrnHuo8FkedfSoNuXGh0swDQYJKoZIhvcNAQEF
                        BQAwHTEbMBkGA1UEAwwSbG9naW4udGVzdC5tYXguZ292MB4XDTE1MDIyNjE4NTgy
                        MloXDTM1MDIyNjE4NTgyMlowHTEbMBkGA1UEAwwSbG9naW4udGVzdC5tYXguZ292
                        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl6OO43kdFgZFYNBxBxnW
                        f965G3h0Z1l+CM4rfDoRW7ieIiYnkolsln738hb21M8Q0SXqniKFGaptUNNyTGkB
                        5R8Dk1zljkrh4KdnKhj3gZu2OnjJ8L4ihR0gdiJuXxvVGaI+KcU0b2Ahz4TBi/DZ
                        ts4c4CJFzmdFL57QjOsBT8jgg3tXQDncl+w0kx+fGFaVTS6tIsN18LscFr0lmHEE
                        E0w3vfOu5CP2G3+MPnJ2ij6urmJdsxyRqHdiHKS3ItpCTWMmt5duvlg3QPK/21C9
                        J7nnuDXPSfhym0gihXvdNt71y4aDI3tqXR3eIaz7ljjEO2PDG6yJwMsE23HhEbW9
                        FwIDAQABo2swaTAdBgNVHQ4EFgQUDBhTOWKufUoHOvgmiZO0gFohONIwSAYDVR0R
                        BEEwP4ISbG9naW4udGVzdC5tYXguZ292hilodHRwczovL2xvZ2luLnRlc3QubWF4
                        Lmdvdi9pZHAvc2hpYmJvbGV0aDANBgkqhkiG9w0BAQUFAAOCAQEABmVizMnSUZ0g
                        AB13t0KdmVqdDh3fp0wsuj9XhUyWlaOyWt8FtcKrr4V3eH281Of1VaG4IAgmHynr
                        CyyDlaU+2rN3X9Mnaz2kgt7fYMiVbU945h4h8X8+DqS4fl+HEP0OpSG0rqTAJ1yN
                        A0nmnYZEeKDwJbTUXaL7w5D+4WNNYDpJ+yVEAno98cLPZtgh0NlpdEl09SK/k0Bm
                        aY6ptcDxOa7FfTeQX9GUmulJTErLen/QHoQf6mQN14y1woXwI/kPpAD8C4Wi5N/P
                        Z00nZfcqMpeatQMt91IiI2IRSInyZ8UU0UqdY3XIJFDDoXyK/SsI5NBZksz0MrbG
                        lJsgPWOAxg==',
        /*
         *  Instead of use the whole x509cert you can use a fingerprint in order to
         *  validate a SAMLResponse.
         *  (openssl x509 -noout -fingerprint -in "idp.crt" to generate it,
         *   or add for example the -sha256 , -sha384 or -sha512 parameter)
         *
         *  If a fingerprint is provided, then the certFingerprintAlgorithm is required in order to
         *  let the toolkit know which algorithm was used. Possible values: sha1, sha256, sha384 or sha512
         *  'sha1' is the default value.
         *
         *  Notice that if you want to validate any SAML Message sent by the HTTP-Redirect binding, you
         *  will need to provide the whole x509cert.
         */
        // 'certFingerprint' => '',
        // 'certFingerprintAlgorithm' => 'sha1',
    ),
// Compression settings
    'compress' => array (
        'requests' => true,
        'responses' => true
    ),
    // Security settings
    'security' => array (

        /** signatures and encryptions offered */

        // Indicates that the nameID of the <samlp:logoutRequest> sent by this SP
        // will be encrypted.
        'nameIdEncrypted' => false,

        // Indicates whether the <samlp:AuthnRequest> messages sent by this SP
        // will be signed.  [Metadata of the SP will offer this info]
        'authnRequestsSigned' => false,

        // Indicates whether the <samlp:logoutRequest> messages sent by this SP
        // will be signed.
        'logoutRequestSigned' => false,

        // Indicates whether the <samlp:logoutResponse> messages sent by this SP
        // will be signed.
        'logoutResponseSigned' => false,

        /* Sign the Metadata
         False || True (use sp certs) || array (
                                                    keyFileName => 'metadata.key',
                                                    certFileName => 'metadata.crt'
                                                )
        */
        'signMetadata' => false,


        /** signatures and encryptions required **/

        // Indicates a requirement for the <samlp:Response>, <samlp:LogoutRequest>
        // and <samlp:LogoutResponse> elements received by this SP to be signed.
        'wantMessagesSigned' => false,

        // Indicates a requirement for the <saml:Assertion> elements received by
        // this SP to be encrypted.
        'wantAssertionsEncrypted' => false,

        // Indicates a requirement for the <saml:Assertion> elements received by
        // this SP to be signed. [Metadata of the SP will offer this info]
        'wantAssertionsSigned' => false,

        // Indicates a requirement for the NameID element on the SAMLResponse
        // received by this SP to be present.
        'wantNameId' => true,

        // Indicates a requirement for the NameID received by
        // this SP to be encrypted.
        'wantNameIdEncrypted' => false,


        // Authentication context.
        // Set to false or don't present this parameter and no AuthContext will be sent in the AuthNRequest,
        // Set true and you will get an AuthContext 'exact' 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport'
        // Set an array with the possible auth context values: array ('urn:oasis:names:tc:SAML:2.0:ac:classes:Password', 'urn:oasis:names:tc:SAML:2.0:ac:classes:X509'),
        'requestedAuthnContext' => true,

        // Indicates if the SP will validate all received xmls.
        // (In order to validate the xml, 'strict' and 'wantXMLValidation' must be true).
        'wantXMLValidation' => true,

        // Algorithm that the toolkit will use on signing process. Options:
        //    'http://www.w3.org/2000/09/xmldsig#rsa-sha1'
        //    'http://www.w3.org/2000/09/xmldsig#dsa-sha1'
        //    'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256'
        //    'http://www.w3.org/2001/04/xmldsig-more#rsa-sha384'
        //    'http://www.w3.org/2001/04/xmldsig-more#rsa-sha512'
        'signatureAlgorithm' => 'http://www.w3.org/2000/09/xmldsig#rsa-sha1',

        // ADFS URL-Encodes SAML data as lowercase, and the toolkit by default uses
        // uppercase. Turn it True for ADFS compatibility on signature verification
        'lowercaseUrlencoding' => false,
    ),

    // Contact information template, it is recommended to supply a
    // technical and support contacts.
    'contactPerson' => array (
        'technical' => array (
            'givenName' => 'Alex',
            'emailAddress' => 'test@example.com'
        ),
        'support' => array (
            'givenName' => 'Alex',
            'emailAddress' => 'test@example.com'
        ),
    ),

    // Organization information template, the info in en_US lang is
    // recomended, add more if required.
    'organization' => array (
        'en-US' => array(
            'name' => 'GSA',
            'displayname' => 'GSA',
            'url' => $config['base_url']
        ),
    )
);


/*
|--------------------------------------------------------------------------
| Github Settings
|--------------------------------------------------------------------------
| You can register new applications at:
|
| 	https://github.com/settings/applications/new
*/

// OAuth Settings
$config['github_oauth_id'] = getenv('GITHUB_OATH_ID');
$config['github_oauth_secret'] = getenv('GITHUB_OATH_SECRET');

// You shouldn't need to edit this unless you haven't specified a 'base_url'
$config['github_oauth_redirect'] = $config['base_url'] . '/dashboard/auth/session/github';


/*
|--------------------------------------------------------------------------
| Index File
|--------------------------------------------------------------------------
|
| Typically this will be your index.php file, unless you've renamed it to
| something else. If you are using mod_rewrite to remove the page set this
| variable so that it is blank.
|
*/
$config['index_page'] = '';

/*
|--------------------------------------------------------------------------
| URI PROTOCOL
|--------------------------------------------------------------------------
|
| This item determines which server global should be used to retrieve the
| URI string.  The default setting of 'AUTO' works for most servers.
| If your links do not seem to work, try one of the other delicious flavors:
|
| 'AUTO'			Default - auto detects
| 'PATH_INFO'		Uses the PATH_INFO
| 'QUERY_STRING'	Uses the QUERY_STRING
| 'REQUEST_URI'		Uses the REQUEST_URI
| 'ORIG_PATH_INFO'	Uses the ORIG_PATH_INFO
|
*/
$config['uri_protocol'] = 'AUTO';

/*
|--------------------------------------------------------------------------
| URL suffix
|--------------------------------------------------------------------------
|
| This option allows you to add a suffix to all URLs generated by CodeIgniter.
| For more information please see the user guide:
|
| http://codeigniter.com/user_guide/general/urls.html
*/

$config['url_suffix'] = '';

/*
|--------------------------------------------------------------------------
| Default Language
|--------------------------------------------------------------------------
|
| This determines which set of language files should be used. Make sure
| there is an available translation if you intend to use something other
| than english.
|
*/
$config['language'] = 'english';

/*
|--------------------------------------------------------------------------
| Default Character Set
|--------------------------------------------------------------------------
|
| This determines which character set is used by default in various methods
| that require a character set to be provided.
|
*/
$config['charset'] = 'UTF-8';

/*
|--------------------------------------------------------------------------
| Enable/Disable System Hooks
|--------------------------------------------------------------------------
|
| If you would like to use the 'hooks' feature you must enable it by
| setting this variable to TRUE (boolean).  See the user guide for details.
|
*/
$config['enable_hooks'] = FALSE;


/*
|--------------------------------------------------------------------------
| Class Extension Prefix
|--------------------------------------------------------------------------
|
| This item allows you to set the filename/classname prefix when extending
| native libraries.  For more information please see the user guide:
|
| http://codeigniter.com/user_guide/general/core_classes.html
| http://codeigniter.com/user_guide/general/creating_libraries.html
|
*/
$config['subclass_prefix'] = 'MY_';


/*
|--------------------------------------------------------------------------
| Allowed URL Characters
|--------------------------------------------------------------------------
|
| This lets you specify with a regular expression which characters are permitted
| within your URLs.  When someone tries to submit a URL with disallowed
| characters they will get a warning message.
|
| As a security measure you are STRONGLY encouraged to restrict URLs to
| as few characters as possible.  By default only these are allowed: a-z 0-9~%.:_-
|
| Leave blank to allow all characters -- but only if you are insane.
|
| DO NOT CHANGE THIS UNLESS YOU FULLY UNDERSTAND THE REPERCUSSIONS!!
|
*/
$config['permitted_uri_chars'] = 'a-z 0-9~%.:_\-';


/*
|--------------------------------------------------------------------------
| Enable Query Strings
|--------------------------------------------------------------------------
|
| By default CodeIgniter uses search-engine friendly segment based URLs:
| example.com/who/what/where/
|
| By default CodeIgniter enables access to the $_GET array.  If for some
| reason you would like to disable it, set 'allow_get_array' to FALSE.
|
| You can optionally enable standard query string based URLs:
| example.com?who=me&what=something&where=here
|
| Options are: TRUE or FALSE (boolean)
|
| The other items let you set the query string 'words' that will
| invoke your controllers and its functions:
| example.com/index.php?c=controller&m=function
|
| Please note that some of the helpers won't work as expected when
| this feature is enabled, since CodeIgniter is designed primarily to
| use segment based URLs.
|
*/
$config['allow_get_array'] = TRUE;
$config['enable_query_strings'] = FALSE;
$config['controller_trigger'] = 'c';
$config['function_trigger'] = 'm';
$config['directory_trigger'] = 'd'; // experimental not currently in use

/*
|--------------------------------------------------------------------------
| Error Logging Threshold
|--------------------------------------------------------------------------
|
| If you have enabled error logging, you can set an error threshold to
| determine what gets logged. Threshold options are:
| You can enable error logging by setting a threshold over zero. The
| threshold determines what gets logged. Threshold options are:
|
|	0 = Disables logging, Error logging TURNED OFF
|	1 = Error Messages (including PHP errors)
|	2 = Debug Messages
|	3 = Informational Messages
|	4 = All Messages
|
| For a live site you'll usually only enable Errors (1) to be logged otherwise
| your log files will fill up very fast.
|
*/
$config['log_threshold'] = 0;

/*
|--------------------------------------------------------------------------
| Error Logging Directory Path
|--------------------------------------------------------------------------
|
| Leave this BLANK unless you would like to set something other than the default
| application/logs/ folder. Use a full server path with trailing slash.
|
*/
$config['log_path'] = '';

/*
|--------------------------------------------------------------------------
| Date Format for Logs
|--------------------------------------------------------------------------
|
| Each item that is logged has an associated date. You can use PHP date
| codes to set your own date formatting
|
*/
$config['log_date_format'] = 'Y-m-d H:i:s';

/*
|--------------------------------------------------------------------------
| Cache Directory Path
|--------------------------------------------------------------------------
|
| Leave this BLANK unless you would like to set something other than the default
| system/cache/ folder.  Use a full server path with trailing slash.
|
*/
$config['cache_path'] = '';

/*
|--------------------------------------------------------------------------
| Encryption Key
|--------------------------------------------------------------------------
|
| If you use the Encryption class or the Session class you
| MUST set an encryption key.  See the user guide for info.
|
*/
$config['encryption_key'] = getenv('ENCRYPTION_KEY');


/*
|--------------------------------------------------------------------------
| Session Variables
|--------------------------------------------------------------------------
|
| 'sess_cookie_name'		= the name you want for the cookie
| 'sess_expiration'			= the number of SECONDS you want the session to last.
|   by default sessions last 7200 seconds (two hours).  Set to zero for no expiration.
| 'sess_expire_on_close'	= Whether to cause the session to expire automatically
|   when the browser window is closed
| 'sess_encrypt_cookie'		= Whether to encrypt the cookie
| 'sess_use_database'		= Whether to save the session data to a database
| 'sess_table_name'			= The name of the session database table
| 'sess_match_ip'			= Whether to match the user's IP address when reading the session data
| 'sess_match_useragent'	= Whether to match the User Agent when reading the session data
| 'sess_time_to_update'		= how many seconds between CI refreshing Session Information
|
*/
$config['sess_cookie_name'] = 'ci_session_dashboard';
$config['sess_expiration'] = 7200;
$config['sess_expire_on_close'] = FALSE;
$config['sess_encrypt_cookie'] = FALSE;
$config['sess_use_database'] = TRUE;
$config['sess_table_name'] = 'ci_sessions';
$config['sess_match_ip'] = FALSE;
$config['sess_match_useragent'] = TRUE;
$config['sess_time_to_update'] = 300;

/*
|--------------------------------------------------------------------------
| Cookie Related Variables
|--------------------------------------------------------------------------
|
| 'cookie_prefix' = Set a prefix if you need to avoid collisions
| 'cookie_domain' = Set to .your-domain.com for site-wide cookies
| 'cookie_path'   =  Typically will be a forward slash
| 'cookie_secure' =  Cookies will only be set if a secure HTTPS connection exists.
|
*/
$config['cookie_prefix'] = "";
$config['cookie_domain'] = "";
$config['cookie_path'] = "/";
$config['cookie_secure'] = FALSE;

/*
|--------------------------------------------------------------------------
| Global XSS Filtering
|--------------------------------------------------------------------------
|
| Determines whether the XSS filter is always active when GET, POST or
| COOKIE data is encountered
|
*/
$config['global_xss_filtering'] = FALSE;

/*
|--------------------------------------------------------------------------
| Cross Site Request Forgery
|--------------------------------------------------------------------------
| Enables a CSRF cookie token to be set. When set to TRUE, token will be
| checked on a submitted form. If you are accepting user data, it is strongly
| recommended CSRF protection be enabled.
|
| 'csrf_token_name' = The token name
| 'csrf_cookie_name' = The cookie name
| 'csrf_expire' = The number in seconds the token should expire.
*/
$config['csrf_protection'] = FALSE;
$config['csrf_token_name'] = 'csrf_test_name';
$config['csrf_cookie_name'] = 'csrf_cookie_name';
$config['csrf_expire'] = 7200;

/*
|--------------------------------------------------------------------------
| Output Compression
|--------------------------------------------------------------------------
|
| Enables Gzip output compression for faster page loads.  When enabled,
| the output class will test whether your server supports Gzip.
| Even if it does, however, not all browsers support compression
| so enable only if you are reasonably sure your visitors can handle it.
|
| VERY IMPORTANT:  If you are getting a blank page when compression is enabled it
| means you are prematurely outputting something to your browser. It could
| even be a line of whitespace at the end of one of your scripts.  For
| compression to work, nothing can be sent before the output buffer is called
| by the output class.  Do not 'echo' any values with compression enabled.
|
*/
$config['compress_output'] = FALSE;

/*
|--------------------------------------------------------------------------
| Master Time Reference
|--------------------------------------------------------------------------
|
| Options are 'local' or 'gmt'.  This pref tells the system whether to use
| your server's local time as the master 'now' reference, or convert it to
| GMT.  See the 'date helper' page of the user guide for information
| regarding date handling.
|
*/
$config['time_reference'] = 'local';


/*
|--------------------------------------------------------------------------
| Rewrite PHP Short Tags
|--------------------------------------------------------------------------
|
| If your PHP installation does not have short tag support enabled CI
| can rewrite the tags on-the-fly, enabling you to utilize that syntax
| in your view files.  Options are TRUE or FALSE (boolean)
|
*/
$config['rewrite_short_tags'] = FALSE;


/*
|--------------------------------------------------------------------------
| Reverse Proxy IPs
|--------------------------------------------------------------------------
|
| If your server is behind a reverse proxy, you must whitelist the proxy IP
| addresses from which CodeIgniter should trust the HTTP_X_FORWARDED_FOR
| header in order to properly identify the visitor's IP address.
| Comma-delimited, e.g. '10.0.1.200,10.0.1.201'
|
*/
$config['proxy_ips'] = '';


/* End of file config.php */
/* Location: ./application/config/config.php */
