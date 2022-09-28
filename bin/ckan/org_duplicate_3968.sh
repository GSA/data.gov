#!/bin/bash
# Query catalog.data.gov for all identifiers that appear more than once
# Parse the organization and dataset ids for duplicate identifiers

# Clear output file
echo "" > output

while read -r data_identifier
do
  duplicates=$(curl -sL "https://catalog.data.gov/api/action/package_search?q=identifier:%22$data_identifier%22")
  organization=$(echo $duplicates | jq -r '.result.results[0].organization.name')
  dataset_id=$(echo $duplicates | jq .result.results[].id)

  # Print the identifier, organization and ids of duplicate dataset
  echo "$data_identifier: $organization: $dataset_id" >> output

done <<< $(curl -sL 'https://catalog.data.gov/api/action/package_search?fq=harvest_source_id:*&facet.field=[%22identifier%22]&facet.limit=-1&facet.mincount=2' | jq -r '.result.facets.identifier' | jq -r keys | jq -r .[])
