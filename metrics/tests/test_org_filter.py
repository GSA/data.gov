"""Regression tests: per-organization GA filters must use the raw org name.

`setup_organization_reports()` builds a GA4 `stringFilter` (CONTAINS) over
`customEvent:DATAGOV_dataset_organization`. GA stores the raw org name sent
by the frontend tracker (e.g. "U.S. Department of Health & Human Services"),
so HTML-escaping the filter value ("&amp;", "&#x27;", ...) makes the filter
match nothing and the published per-org reports come back empty every run.
This already happened in production (HHS metrics page empty while GA4 had
the data).

Org names below are the real ones served by catalog.data.gov/api/organizations.
"""

import sys
import types
import unittest
from unittest.mock import MagicMock


def _load_ga():
    # ga.py talks to Google APIs at import time; stub the heavy deps so
    # these tests run anywhere.
    google = types.ModuleType("google")
    oauth2 = types.ModuleType("google.oauth2")
    service_account = types.ModuleType("google.oauth2.service_account")
    service_account.Credentials = MagicMock()
    discovery = types.ModuleType("googleapiclient.discovery")
    discovery.build = MagicMock(return_value=MagicMock())
    boto3 = types.ModuleType("boto3")
    boto3.client = MagicMock(return_value=MagicMock())
    dotenv = types.ModuleType("dotenv")
    dotenv.load_dotenv = MagicMock()
    requests = types.ModuleType("requests")

    sys.modules["google"] = google
    sys.modules["google.oauth2"] = oauth2
    sys.modules["google.oauth2.service_account"] = service_account
    sys.modules["googleapiclient"] = types.ModuleType("googleapiclient")
    sys.modules["googleapiclient.discovery"] = discovery
    sys.modules["boto3"] = boto3
    sys.modules["dotenv"] = dotenv
    sys.modules["requests"] = requests

    sys.path.insert(0, "datagov_metrics")
    import ga

    return ga


ga = _load_ga()

# Real org shapes from catalog.data.gov/api/organizations: the three names
# containing HTML-special chars, plus one plain name as a control.
REAL_ORGS = [
    {"slug": "hhs-gov", "name": "U.S. Department of Health & Human Services"},
    {"slug": "ibwc-gov", "name": "International Boundary & Water Commission"},
    {"slug": "coeur-d-alene-tribe", "name": "Coeur d'Alene Tribe"},
    {"slug": "doi-gov", "name": "U.S. Department of the Interior"},
]


def _filter_value(report):
    expressions = report.get("dimensionFilter", {}).get("andGroup", {}).get(
        "expressions"
    )
    if expressions is not None:
        # download/link reports nest the org filter inside an andGroup
        for expr in expressions:
            f = expr.get("filter", {})
            if f.get("fieldName") == "customEvent:DATAGOV_dataset_organization":
                return f["stringFilter"]["value"]
        raise AssertionError("org filter missing from andGroup")
    return report["dimensionFilter"]["filter"]["stringFilter"]["value"]


class TestOrgFilterUsesRawName(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        ga.get_org_list = lambda: REAL_ORGS
        cls.reports = ga.setup_organization_reports()

    def test_filter_value_is_raw_org_name(self):
        for org in REAL_ORGS:
            for suffix in ("page_requests", "download_requests", "link_requests"):
                with self.subTest(org=org["slug"], report=suffix):
                    report = self.reports[f"{org['slug']}__{suffix}__last30"]
                    self.assertEqual(_filter_value(report), org["name"])

    def test_filter_matches_what_ga_stores(self):
        # GA stores the raw name; a CONTAINS filter only returns rows when
        # the filter value is a substring of the stored value.
        for org in REAL_ORGS:
            report = self.reports[f"{org['slug']}__page_requests__last30"]
            self.assertIn(_filter_value(report), org["name"])

    def test_ampersand_org_not_html_escaped(self):
        report = self.reports["hhs-gov__page_requests__last30"]
        self.assertNotIn("&amp;", _filter_value(report))

    def test_apostrophe_org_not_html_escaped(self):
        report = self.reports["coeur-d-alene-tribe__page_requests__last30"]
        self.assertNotIn("&#x27;", _filter_value(report))


if __name__ == "__main__":
    unittest.main()
