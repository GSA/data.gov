"""Regression tests for issue #6314: non-ASCII page titles in downloaded
metrics CSVs came out as mojibake (e.g. "Um novo Ã\xadndice").

The payload bytes were valid UTF-8, but with no BOM prefix and no
Content-Type on the S3 object, Excel/browsers decoded them as Latin-1.
"""

import sys
import types
import unittest
from unittest.mock import MagicMock, patch


def _load_modules():
    # ga.py talks to Google APIs at import time; stub the heavy deps so
    # these pure unit tests run anywhere.
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
    import s3_util

    return ga, s3_util


ga, s3_util = _load_modules()

GA_RESPONSE = {
    "dimensionHeaders": [{"name": "pageTitle"}],
    "metricHeaders": [{"name": "eventCount"}],
    "rows": [
        {
            "dimensionValues": [
                {"value": "Um novo índice para medir"},
            ],
            "metricValues": [{"value": "12"}],
        },
        {
            "dimensionValues": [{"value": "연방준비제도"}],
            "metricValues": [{"value": "7"}],
        },
    ],
}


class TestCsvEncoding(unittest.TestCase):
    def test_csv_starts_with_utf8_bom(self):
        csv_data = ga.write_data_to_csv(GA_RESPONSE)
        self.assertTrue(csv_data.startswith("\ufeff"))

    def test_csv_round_trips_non_ascii_titles(self):
        csv_data = ga.write_data_to_csv(GA_RESPONSE)
        self.assertIn("Um novo índice para medir", csv_data)
        self.assertIn("연방준비제도", csv_data)
        # the exact mojibake from the issue must not appear
        self.assertNotIn("Ã\xad", csv_data)

    def test_s3_upload_declares_csv_utf8_content_type(self):
        s3_util.put_data_to_s3("report.csv", "\ufeffa,b\n")
        _, kwargs = s3_util.s3_client.put_object.call_args
        self.assertEqual(kwargs["ContentType"], "text/csv; charset=utf-8")


class TestOrgOutboundLinks(unittest.TestCase):
    def test_org_outbound_report_filters_on_dataset_link_class(self):
        with patch.object(
            ga,
            "get_org_list",
            return_value=[{"slug": "fed-reserve", "name": "Federal Reserve"}],
        ):
            reports = ga.setup_organization_reports()
        outbound = reports["fed-reserve__link_requests__last30"]
        expressions = outbound["dimensionFilter"]["andGroup"]["expressions"]
        link_filters = [
            expression["filter"]
            for expression in expressions
            if expression.get("filter", {}).get("fieldName") == "linkClasses"
        ]

        self.assertEqual(
            link_filters,
            [
                {
                    "fieldName": "linkClasses",
                    "stringFilter": {
                        "matchType": "CONTAINS",
                        "value": "dataset-outbound-link",
                    },
                }
            ],
        )
        for other_report in (
            reports["fed-reserve__download_requests__last30"],
            ga.setup_global_reports()["global__link_requests__last30"],
        ):
            other_expressions = other_report["dimensionFilter"]["andGroup"][
                "expressions"
            ]
            self.assertFalse(
                any(
                    expression.get("filter", {}).get("fieldName") == "linkClasses"
                    for expression in other_expressions
                )
            )


if __name__ == "__main__":
    unittest.main()
