from datetime import datetime, timedelta
import calendar
import io
import csv
from functools import lru_cache
from html import escape
import time

from datagov_metrics.s3_util import put_data_to_s3
import requests
from google.oauth2 import service_account
from googleapiclient.discovery import build

KEY_FILE_LOCATION = "datagov_metrics/credentials.json"
GA4_PROPERTY_ID = "properties/381392243"

SEARCH_RESULTS_LIMIT = 50

credentials = service_account.Credentials.from_service_account_file(
    KEY_FILE_LOCATION, scopes=["https://www.googleapis.com/auth/analytics.readonly"]
)
analytics = build("analyticsdata", "v1beta", credentials=credentials)
properties = analytics.properties()


@lru_cache()
def date_range_last_month():
    last_month = datetime.today().replace(day=1) - timedelta(days=1)
    last_day = calendar.monthrange(last_month.year, last_month.month)[1]
    end_date = datetime(last_month.year, last_month.month, last_day).strftime(
        "%Y-%m-%d"
    )
    start_date = datetime(last_month.year, last_month.month, 1).strftime("%Y-%m-%d")
    return [{"startDate": start_date, "endDate": end_date}]


def get_org_list():
    url = 'https://catalog.data.gov/api/action/package_search?q=*:*&facet.field=["organization"]&facet.limit=200&rows=0'
    repo = requests.get(url)
    data = repo.json()

    return data["result"]["search_facets"]["organization"]["items"]


def setup_organization_reports():
    orgs = get_org_list()
    org_reports = {}

    for org in orgs:
        org_name = org["name"]
        org_display_name = escape(org["display_name"])
        org_dimension_filter = {
            "filter": {
                "fieldName": "customEvent:DATAGOV_dataset_organization",
                "stringFilter": {"matchType": "CONTAINS", "value": org_display_name},
            }
        }

        # report most viewed dataset pages per organization
        org_reports[f"{org_name}__page_requests__last30"] = {
            "dateRanges": date_range_last_month(),
            "dimensions": [
                {"name": "pagePath"},
                {"name": "customEvent:DATAGOV_dataset_organization"},
                {"name": "customEvent:DATAGOV_dataset_publisher"},
            ],
            "dimensionFilter": org_dimension_filter,
            "metrics": [{"name": "screenPageViews"}],
            "orderBys": [{"metric": {"metricName": "screenPageViews"}, "desc": True}],
        }

        # report most downloaded files per organization
        org_reports[f"{org_name}__download_requests__last30"] = {
            "dateRanges": date_range_last_month(),
            "dimensions": [
                {"name": "linkUrl"},
                {"name": "customEvent:DATAGOV_dataset_organization"},
                {"name": "customEvent:DATAGOV_dataset_publisher"},
                {"name": "fileExtension"},
                {"name": "fileName"},
                {"name": "pageLocation"},
                {"name": "pageTitle"},
            ],
            "dimensionFilter": {
                "andGroup": {
                    "expressions": [
                        {
                            "filter": {
                                "fieldName": "eventName",
                                "stringFilter": {
                                    "matchType": "EXACT",
                                    "value": "file_download",
                                },
                            }
                        },
                        org_dimension_filter,
                    ],
                },
            },
            "metrics": [{"name": "eventCount"}],
            "orderBys": [{"metric": {"metricName": "eventCount"}, "desc": True}],
        }

        # report most clicked outboud links per organization
        org_reports[f"{org_name}__link_requests__last30"] = {
            "dateRanges": date_range_last_month(),
            "dimensions": [
                {"name": "linkUrl"},
                {"name": "customEvent:DATAGOV_dataset_organization"},
                {"name": "customEvent:DATAGOV_dataset_publisher"},
                {"name": "outbound"},
                {"name": "pageLocation"},
                {"name": "pageTitle"},
            ],
            "dimensionFilter": {
                "andGroup": {
                    "expressions": [
                        {
                            "filter": {
                                "fieldName": "outbound",
                                "stringFilter": {"matchType": "EXACT", "value": "true"},
                            }
                        },
                        org_dimension_filter,
                    ],
                },
            },
            "metrics": [{"name": "eventCount"}],
            "orderBys": [{"metric": {"metricName": "eventCount"}, "desc": True}],
        }

    return org_reports


def setup_global_reports():
    global_reports = {}

    global_reports["global__page_requests__last30"] = {
        "dateRanges": date_range_last_month(),
        "dimensions": [{"name": "pagePath"}],
        # TODO add filter to clean up pages?
        # "dimensionFilter": {},
        "metrics": [{"name": "screenPageViews"}],
        "orderBys": [{"metric": {"metricName": "screenPageViews"}, "desc": True}],
    }

    global_reports["global__total_pageviews__last30"] = {
        "dateRanges": date_range_last_month(),
        "metrics": [{"name": "screenPageViews"}],
    }

    global_reports["global__device_category__last30"] = {
        "dateRanges": date_range_last_month(),
        "dimensions": [{"name": "deviceCategory"}],
        "metrics": [{"name": "activeUsers"}],
        "orderBys": [{"metric": {"metricName": "activeUsers"}, "desc": True}],
    }

    global_reports["global__download_requests__last30"] = {
        "dateRanges": date_range_last_month(),
        "dimensions": [
            {"name": "linkUrl"},
            {"name": "fileExtension"},
            {"name": "fileName"},
            {"name": "pageLocation"},
            {"name": "pageTitle"},
        ],
        "dimensionFilter": {
            "andGroup": {
                "expressions": [
                    {
                        "filter": {
                            "fieldName": "eventName",
                            "stringFilter": {
                                "matchType": "EXACT",
                                "value": "file_download",
                            },
                        }
                    },
                ],
            },
        },
        "metrics": [{"name": "eventCount"}],
        "orderBys": [{"metric": {"metricName": "eventCount"}, "desc": True}],
    }

    global_reports["global__link_requests__last30"] = {
        "dateRanges": date_range_last_month(),
        "dimensions": [
            {"name": "linkUrl"},
            {"name": "customEvent:DATAGOV_dataset_organization"},
            {"name": "customEvent:DATAGOV_dataset_publisher"},
            {"name": "outbound"},
            {"name": "pageLocation"},
            {"name": "pageTitle"},
        ],
        "dimensionFilter": {
            "andGroup": {
                "expressions": [
                    {
                        "filter": {
                            "fieldName": "outbound",
                            "stringFilter": {"matchType": "EXACT", "value": "true"},
                        }
                    },
                ],
            },
        },
        "metrics": [{"name": "eventCount"}],
        "orderBys": [{"metric": {"metricName": "eventCount"}, "desc": True}],
    }

    return global_reports


def setup_reports():
    reports = {}
    reports.update(setup_global_reports())
    reports.update(setup_organization_reports())

    return reports


def refresh_properties():
    """
    recreate GA "properties". used after waiting for report retry based on quota limit.
    """
    global credentials, analytics, properties
    credentials = service_account.Credentials.from_service_account_file(
        KEY_FILE_LOCATION, scopes=["https://www.googleapis.com/auth/analytics.readonly"]
    )
    analytics = build("analyticsdata", "v1beta", credentials=credentials)
    properties = analytics.properties()


def fetch_report(request, max_retries=3, initial_delay=900):
    """
    fetch report with exponential backoff to account for GA
    "Core Tokens Per Project Per Property Per Hour" quota limit.
    initial wait time is 15 minutes with a maximum wait of 1 hour.
    """
    for attempt in range(max_retries):
        try:
            return properties.runReport(
                property=GA4_PROPERTY_ID, body=request
            ).execute()
        except Exception as e:
            if "exhausted property tokens" in str(e).lower():
                print(
                    f"Quota error encountered. Retrying in {initial_delay * (2**attempt)} seconds."
                )
                time.sleep(initial_delay * (2**attempt))
                refresh_properties()
            else:
                raise e
    raise Exception("Max retries reached for report request.")


def write_data_to_csv(response):
    """Reshape the response CSV."""
    with io.StringIO() as csv_buffer:
        writer = csv.writer(csv_buffer, delimiter=",")
        writer.writerow(
            [
                *[val["name"] for val in response.get("dimensionHeaders") or []],
                *[val["name"] for val in response["metricHeaders"]],
            ]
        )  # write header
        if response.get("rows"):
            writer.writerows(
                [
                    *[val["value"] for val in row.get("dimensionValues") or []],
                    *[val["value"] for val in row["metricValues"]],
                ]
                for row in response["rows"]
            )
        return csv_buffer.getvalue()


def main():
    reports = setup_reports()
    end_date = date_range_last_month()[0]["endDate"]  # for example, 2024-10-31
    for report in reports:
        print(f"Fetching report: {report}")
        fetched_report = fetch_report(reports[report])
        csv_data = write_data_to_csv(fetched_report)
        put_data_to_s3(f"{report}.{end_date}.csv", csv_data)

    # This file get refreshed every time at the end of report generation
    put_data_to_s3("report-end-date.txt", end_date)


if __name__ == "__main__":
    main()
