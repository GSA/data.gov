#!/bin/bash

route_to_check='https://catalog-prod-admin-datagov.app.cloud.gov'

organization_with_0_datasets=0

while read -r org
do
  dataset_count=$(curl -sL "$route_to_check/api/action/package_search?fq=organization:$org" | jq .result.count)
  if [[ "$dataset_count" = "0" ]]; then
    export organization_with_0_datasets=$(( organization_with_0_datasets + 1 ))
  fi
  echo "$org: $dataset_count"
done <<< $(curl -sL "$route_to_check/api/action/organization_list" | jq -rc .result[])

echo "$organization_with_0_datasets organizations with 0 datasets"
