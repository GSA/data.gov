#!/bin/bash

echo "starting..."
spaces=$(cf spaces | awk -F'Getting' '{print $1}' | awk -F'name' '{print $1}')

echo 'space, name, guid, service' > AWS_resource_inventory.csv
output1=""
output2=""
output3=""

for space in $spaces
do
    echo $space
    output=$(cf t -s $space)

    # get list of solr-on-ecs service
    service='solr-on-ecs'
    solr_on_ecs_services=$(cf s | grep $service | awk '{print $1}')
    for name in $solr_on_ecs_services
    do 
        if [[ $space == 'development' || $space == 'staging' || $space == 'prod' ]] \
            && [[ $name == 'catalog-solr' || $name == 'inventory-solr' ]]
        then
            output1+="$space, $name, $(cf service $name --guid), $service\n"
        else
            output2+="$space, $name, $(cf service $name --guid), $service\n"
        fi
    done

    # # get list of aws-eks-service service
    service='aws-eks-service'
    aws_eks_service_services=$(cf s | grep $service | awk '{print $1}')
    for name in $aws_eks_service_services
    do 
        output3+="$space, $name, $(cf service $name --guid), $service\n"
    done
done

echo -e $output1 >> AWS_resource_inventory.csv
echo -e $output2 >> AWS_resource_inventory.csv
echo -e $output3 >> AWS_resource_inventory.csv

echo "### Done. Pleaes upload AWS_resource_inventory.csv to 'system inventory' on google drive. ### "