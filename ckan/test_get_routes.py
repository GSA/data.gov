
from ckan.tests.helpers import CKANTestApp, CKANTestClient
import ckan.config.middleware
from ckan.common import config
import ckan.plugins

from flask import Flask, url_for
from  werkzeug.routing import BuildError
import pytest

# Catalog plugins
# @pytest.mark.ckan_config('ckan.plugins', 'image_view text_view recline_view qa archiver report ckan_harvester datajson_validator datajson_harvest geodatagov datagovtheme datagov_harvest geodatagov_miscs z3950_harvester arcgis_harvester geodatagov_geoportal_harvester waf_harvester_collection geodatagov_csw_harvester geodatagov_doc_harvester geodatagov_waf_harvester spatial_metadata spatial_query spatial_harvest_metadata_api googleanalyticsbasic dcat dcat_json_interface structured_data datagovcatalog saml2auth envvars')
# Inventory plugins
@pytest.mark.ckan_config('ckan.plugins', 'datagov_inventory datastore xloader stats text_view recline_view googleanalyticsbasic s3filestore dcat_usmetadata usmetadata datajson saml2auth envvars')
@pytest.mark.use_fixtures('with_plugins','with_request_context')
class TestRoutes():

    def test_get_routes(self, app):
        assert ckan.plugins.plugin_loaded('envvars')

        links = []
        for rule in app.app._wsgi_app.url_map.iter_rules():
            print(dir(rule))
            links.append((rule.rule, rule.endpoint))

        with open('/temp/routes.txt', 'w') as f:
            for l in links:
                f.write(str(l))
                f.write('\n')
