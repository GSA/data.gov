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
                        'MIIDHzCCAgegAwIBAgIUPdRdrl5geFw6rcdLCg9XQr5fpqowDQYJKoZIhvcNAQEF
                        BQAwGDEWMBQGA1UEAwwNbG9naW4ubWF4LmdvdjAeFw0xNTAyMjcxNzM0MjVaFw0z
                        NTAyMjcxNzM0MjVaMBgxFjAUBgNVBAMMDWxvZ2luLm1heC5nb3YwggEiMA0GCSqG
                        SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCP/XwjR/J27ORJWOdK+Kfj3UE74x2OrrVp
                        RvBGRkzv34YY7bSApD0s/WOz2h4fHa496LSZ8mc2ZmY6Tcmq2U1Sy+W6wECPr/Bj
                        ZXpJPzAh3BBnrnO41lD8RIHBmpvPxPsOdrGwxOwVggg86fN31RI0gBHcbn3KPz7s
                        K/9cHC55QL01qzpjhCCp1cZ2ZrEzfu3V1jpRoIsOYWIXlbj2Fn+rziOUrnUO+eMF
                        pwDeifJqKUXBV7ZM8VejC9Z60uNmV2JPm9CHnjhCxul0fAChm+vPsw1DneoAw1m1
                        LZk/SmuKqFVHuLVBn32I/lUuK/ugr8ww1FPMaqtdR46s5bTe+tYTAgMBAAGjYTBf
                        MB0GA1UdDgQWBBRky4lFS031okDAefZKehA27/DZIDA+BgNVHREENzA1gg1sb2dp
                        bi5tYXguZ292hiRodHRwczovL2xvZ2luLm1heC5nb3YvaWRwL3NoaWJib2xldGgw
                        DQYJKoZIhvcNAQEFBQADggEBAD/dpBgAQMwbHakIDukwDOX2GBWu+l+jZt/1KqlZ
                        YuxeNjRB54rZp70SOkARlUtWP8fdm6Lp1R1JxzqIsI8nde0lBCXw21lGQDzXVm+z
                        rMmsS/KS9N1WM9Wqg0VJgTC4EHnK1OxfUVfH6gG6GV8+pSTv2tM2SKBiG5cQ9g/i
                        2mh/M8aPg05TA+IZCMOnKIgnkEq3YhI2OS80a9qrSKZh8X4/+DklGHWzbdOV8pW0
                        CQ3LQo/QLeCJHTdqga2i5y0aKcyX3d7pNlJZh1PMInz9Lmd4WFHllaDgRxWsWCRW
                        x1DFvVHKK/lPRTV+5Emt3dzy+gVd1ZnSxCVbkt2SswlPdGI=',
                ),
        ),
    'scope' =>
        array (
            0 => 'max.gov',
        ),
);