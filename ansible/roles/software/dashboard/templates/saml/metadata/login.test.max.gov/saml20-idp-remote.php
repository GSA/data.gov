<?php


$metadata['https://{{ saml2_idp_entry }}/idp/shibboleth'] = array (
    'entityid' => 'https://{{ saml2_idp_entry }}/idp/shibboleth',
    'contacts' =>
        array (
        ),
    'metadata-set' => 'saml20-idp-remote',
    'SingleSignOnService' =>
        array (
            0 =>
                array (
                    'Binding' => 'urn:mace:shibboleth:1.0:profiles:AuthnRequest',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/Shibboleth/SSO',
                ),
            1 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/SAML2/POST/SSO',
                ),
            2 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/SAML2/POST-SimpleSign/SSO',
                ),
            3 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/SAML2/Redirect/SSO',
                ),
        ),
    'SingleLogoutService' =>
        array (
            0 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/SAML2/Redirect/SLO',
                ),
            1 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/SAML2/POST/SLO',
                ),
            2 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/SAML2/SOAP/SLO',
                ),
        ),
    'ArtifactResolutionService' =>
        array (
            0 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/SAML1/SOAP/ArtifactResolution',
                    'index' => 1,
                ),
            1 =>
                array (
                    'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
                    'Location' => 'https://{{ saml2_idp_entry }}/idp/profile/SAML2/SOAP/ArtifactResolution',
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
                    'X509Certificate' =>
                        'MIIDMzCCAhugAwIBAgIUGZmNOfGrnHuo8FkedfSoNuXGh0swDQYJKoZIhvcNAQEF
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
                ),
        ),
    'scope' =>
        array (
            0 => 'max.gov',
        ),
);