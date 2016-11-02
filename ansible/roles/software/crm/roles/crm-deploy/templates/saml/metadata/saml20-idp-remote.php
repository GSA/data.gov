<?php


$metadata['https://{{ saml_idp_host }}/idp/shibboleth'] = array (
    'entityid' => 'https://{{ saml_idp_host }}/idp/shibboleth',
    'contacts' =>
        array (
        ),
    'metadata-set' => 'saml20-idp-remote',
    'SingleSignOnService' =>
        array (
            0 =>
                array (
                    'Binding' => 'urn:mace:shibboleth:1.0:profiles:AuthnRequest',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/Shibboleth/SSO',
                ),
            1 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/SAML2/POST/SSO',
                ),
            2 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/SAML2/POST-SimpleSign/SSO',
                ),
            3 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/SAML2/Redirect/SSO',
                ),
        ),
    'SingleLogoutService' =>
        array (
            0 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/SAML2/Redirect/SLO',
                ),
            1 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/SAML2/POST/SLO',
                ),
            2 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/SAML2/SOAP/SLO',
                ),
        ),
    'ArtifactResolutionService' =>
        array (
            0 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/SAML1/SOAP/ArtifactResolution',
                    'index' => 1,
                ),
            1 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
                    'Location' => 'https://{{ saml_idp_host }}/idp/profile/SAML2/SOAP/ArtifactResolution',
                    'index' => 2,
                ),
        ),
//    'EntityAttributes' => array(
//        'urn:simplesamlphp:v1:simplesamlphp' => array('is', 'really', 'cool'),
//        '{urn:simplesamlphp:v1}foo'          => array('bar'),
//    ),
    'NameIDFormats' =>
        array (
            0 => 'urn:mace:shibboleth:1.0:nameIdentifier',
            1 => 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
        ),
    'keys' =>
        array (
            0 =>
                array (
                    'encryption' => false,
                    'signing' => true,
                    'type' => 'X509Certificate',
                    'X509Certificate' => '{{ saml_idp_cert }}',
                ),
        ),
    'scope' =>
        array (
            0 => 'max.gov',
        ),
);