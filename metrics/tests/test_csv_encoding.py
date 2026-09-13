"""Regression tests for issue #6314: non-ASCII page titles in downloaded
metrics CSVs came out as mojibake (e.g. "Um novo Ã\xadndice").

The payload bytes were valid UTF-8, but with no BOM prefix and no
Content-Type on the S3 object, Excel/browsers decoded them as Latin-1.
"""

import sys
import types
from unittest.mock import MagicMock


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


def test_csv_starts_with_utf8_bom():
    csv_data = ga.write_data_to_csv(GA_RESPONSE)
    assert csv_data.startswith("\ufeff")


def test_csv_round_trips_non_ascii_titles():
    csv_data = ga.write_data_to_csv(GA_RESPONSE)
    assert "Um novo índice para medir" in csv_data
    assert "연방준비제도" in csv_data
    # the exact mojibake from the issue must not appear
    assert "Ã\xad" not in csv_data


def test_s3_upload_declares_csv_utf8_content_type():
    s3_util.put_data_to_s3("report.csv", "\ufeffa,b\n")
    _, kwargs = s3_util.s3_client.put_object.call_args
    assert kwargs["ContentType"] == "text/csv; charset=utf-8"
