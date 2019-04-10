<?php


$protocol = 'https';

$default_host = '{{ default_host }} ';
if (isset($_SERVER['HTTP_HOST']) && $_SERVER['HTTP_HOST']) {
    $default_host = $_SERVER['HTTP_HOST'];
}

$base_url = $protocol . '://' . $default_host;

if (0 === stripos($_SERVER['REQUEST_URI'], '/dashboard')){
    $base_url .= '/dashboard';
}

$config = array(
    // This is a authentication source which handles admin authentication.
    'admin' => array(
        // The default is to use core:AdminPassword, but it can be replaced with
        // any authentication source.

        'core:AdminPassword',
    ),

    /* This is the name of this authentication source, and will be used to access it later. */
    'max' => array(
        'saml:SP',
        'entityID' => $base_url,
        'idp' => 'https://{{ saml2_idp_entry }}/idp/shibboleth',
        'privatekey' => '{{ saml_sp_private_key_path }}',
        'certificate' => '{{ saml_sp_cert_path }}',
        'NameIDFormat' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',
        'NameIDPolicy' => FALSE,
    ),
);
