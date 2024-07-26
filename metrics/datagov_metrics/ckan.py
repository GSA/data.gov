import requests
import csv
import io
from datagov_metrics.s3_util import put_data_to_s3

CKAN_BASE_URL = "https://catalog.data.gov/api/action/package_search"
QUERIES = {
    "harvest_sources": '?fq=dataset_type:harvest&facet.field=["organization"]&facet.limit=200&rows=0',
    "datasets_per_org": '?q=*:*&facet.field=["organization"]&facet.limit=200&rows=0',
}


def get_data():
    query_dict = {}
    for k, v in QUERIES.items():
        url = f"{CKAN_BASE_URL}{v}"
        repo = requests.get(url)
        data = repo.json()

        raw_data = data["result"]["facets"]["organization"]

        query_dict[k] = [[k, v] for (k, v) in raw_data.items()]
    return query_dict


def write_data_to_csv(response):
    """Reshape the response CSV."""
    with io.StringIO() as csv_buffer:
        writer = csv.writer(csv_buffer, delimiter=",")
        writer.writerow(["organization", "count"])  # write header
        writer.writerows(response)
        return csv_buffer.getvalue()


def main():
    data = get_data()
    for k, v in data.items():
        csv_data = write_data_to_csv(v)
        put_data_to_s3(f"global__{k}.csv", csv_data)


if __name__ == "__main__":
    main()
