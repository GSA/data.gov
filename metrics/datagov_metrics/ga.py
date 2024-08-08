from datetime import datetime, timedelta
import calendar
import io
import csv

from datagov_metrics.s3_util import put_data_to_s3
import requests
from google.oauth2 import service_account
from googleapiclient.discovery import build

KEY_FILE_LOCATION = "datagov_metrics/credentials.json"
GA4_PROPERTY_ID = "properties/381392243"

credentials = service_account.Credentials.from_service_account_file(
    KEY_FILE_LOCATION, scopes=["https://www.googleapis.com/auth/analytics.readonly"]
)
analytics = build("analyticsdata", "v1beta", credentials=credentials)
properties = analytics.properties()


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
        org_display_name = org["display_name"]
        org_dimension_filter = {
            "filter": {
                "fieldName": "customEvent:DATAGOV_dataset_organization",
                "stringFilter": {"matchType": "CONTAINS", "value": org_display_name},
            }
        }

        # report most viewd dataset pages per organization
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

    global_reports["global__top_search_terms__last30"] = {
        "dateRanges": date_range_last_month(),
        "dimensions": [{"name": "searchTerm"}],
        "dimensionFilter": {
            "andGroup": {
                "expressions": [
                    {
                        "notExpression": {
                            "filter": {
                                "fieldName": "searchTerm",
                                "stringFilter": {"matchType": "EXACT", "value": ""},
                            }
                        }
                    },
                    {
                        "notExpression": {
                            "filter": {
                                "fieldName": "searchTerm",
                                "stringFilter": {
                                    "matchType": "EXACT",
                                    "value": "Search datasets...",
                                },
                            }
                        }
                    },
                ]
            }
        },
        "metrics": [{"name": "eventCount"}],
        "orderBys": [{"metric": {"metricName": "eventCount"}, "desc": True}],
    }

    global_reports["global__device_category__last30"] = {
        "dateRanges": date_range_last_month(),
        "dimensions": [{"name": "deviceCategory"}],
        "metrics": [{"name": "activeUsers"}],
        "orderBys": [{"metric": {"metricName": "activeUsers"}, "desc": True}],
    }

    return global_reports


def setup_reports():
    reports = {}
    reports.update(setup_global_reports())
    reports.update(setup_organization_reports())

    return reports


def fetch_report(request):
    response = properties.runReport(property=GA4_PROPERTY_ID, body=request).execute()
    return response


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
    for report in reports:
        print(f"Fetching report: {report}")
        fetched_report = fetch_report(reports[report])
        csv_data = write_data_to_csv(fetched_report)
        put_data_to_s3(f"{report}.csv", csv_data)


if __name__ == "__main__":
    main()
