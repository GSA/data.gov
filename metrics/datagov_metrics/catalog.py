import requests
import csv
import io
import logging
from datagov_metrics.s3_util import put_data_to_s3
from datagov_metrics.ga import date_range_last_month

logger = logging.getLogger(__name__)


def get_data() -> tuple[dict, list[str]]:
    output = {}
    errors = []

    queries = {
        "harvest_sources": "https://harvest.data.gov/api/organizations/?paginate=false",
        "datasets_per_org": "https://catalog.data.gov/api/organizations",
    }

    for report_name, query in queries.items():
        try:
            res = requests.get(query)
            res.raise_for_status()
            data = res.json()
            count_key = "source_count"
            if report_name == "datasets_per_org":
                data = data["organizations"]
                count_key = "dataset_count"
            output[report_name] = [[org["slug"], org[count_key]] for org in data]
        except (KeyError, TypeError, ValueError, requests.RequestException) as e:
            logger.exception(
                "Failed to fetch catalog metrics report %s from %s",
                report_name,
                query,
            )
            errors.append(f"{report_name} ({query}): {e}")

    return output, errors


def write_data_to_csv(response):
    """Reshape the response CSV."""
    with io.StringIO() as csv_buffer:
        writer = csv.writer(csv_buffer, delimiter=",")
        writer.writerow(["organization", "count"])  # write header
        writer.writerows(response)
        return csv_buffer.getvalue()


def main():
    data, errors = get_data()
    end_date = date_range_last_month()[0]["endDate"]  # for example, 2024-10-31
    for k, v in data.items():
        csv_data = write_data_to_csv(v)
        put_data_to_s3(f"global__{k}.{end_date}.csv", csv_data)

    if errors:
        error_messages = "\n".join(errors)
        raise RuntimeError(f"Catalog metrics report fetch failed:\n{error_messages}")


if __name__ == "__main__":
    main()
