#!/bin/bash

route_to_check='https://catalog-prod-admin-datagov.app.cloud.gov'

organization_with_0_datasets=0

curl -sL $route_to_check/api/action/organization_list | jq -rc .result[] | while read -r org
do
  dataset_count=$(curl -sL "$route_to_check/api/action/package_search?fq=organization:$org" | jq .result.count)
  if [[ "$dataset_count" = "0" ]]; then
    organization_with_0_datasets=$(($organization_with_0_datasets+1))
  fi
  echo "$org: $dataset_count"
  echo $organization_with_0_datasets with 0 datasets
done

