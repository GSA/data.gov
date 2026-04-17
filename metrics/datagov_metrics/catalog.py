import requests
import csv
import io
from datagov_metrics.s3_util import put_data_to_s3
from datagov_metrics.ga import date_range_last_month


def get_data() -> dict:
    output = {}

    queries = {
        "harvest_sources": "https://harvest.data.gov/organizations/?paginate=false",
        "datasets_per_org": "https://catalog.data.gov/api/organizations",
    }

    for report_name, query in queries.items():
        res = requests.get(query)
        if res.ok:
            data = res.json()
            count_key = "source_count"
            if report_name == "datasets_per_org":
                data = data["organizations"]
                count_key = "dataset_count"
            output[report_name] = [[org["slug"], org[count_key]] for org in data]

    return output


def write_data_to_csv(response):
    """Reshape the response CSV."""
    with io.StringIO() as csv_buffer:
        writer = csv.writer(csv_buffer, delimiter=",")
        writer.writerow(["organization", "count"])  # write header
        writer.writerows(response)
        return csv_buffer.getvalue()


def main():
    data = get_data()
    end_date = date_range_last_month()[0]["endDate"]  # for example, 2024-10-31
    for k, v in data.items():
        csv_data = write_data_to_csv(v)
        put_data_to_s3(f"global__{k}.{end_date}.csv", csv_data)


if __name__ == "__main__":
    main()
