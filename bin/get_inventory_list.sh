#! /bin/bash

echo "starting..."
spaces=$(cf spaces | awk -F'Getting' '{print $1}' | awk -F'name' '{print $1}')

echo 'space, name, guid, service' > AWS_resource_inventory.csv
echo '' > temp1.csv
echo '' > temp2.csv
for space in $spaces
do
    echo $space
    output=$(cf t -s $space)

    # get list of solr-on-ecs service
    service='solr-on-ecs'
    solr_on_ecs_services=$(cf s | grep $service | awk '{print $1}')
    for name in $solr_on_ecs_services
    do 
        if ([ $space == 'development' ] && [ $name == 'catalog-solr' ]) \
            || ([ $space == 'development' ] && [ $name == 'inventory-solr' ]) \
            || ([ $space == 'staging' ] && [ $name == 'catalog-solr' ]) \
            || ([ $space == 'staging' ] && [ $name == 'inventory-solr' ]) \
            || ([ $space == 'prod' ] && [ $name == 'catalog-solr' ]) \
            || ([ $space == 'prod' ] && [ $name == 'inventory-solr' ]) then

            echo $space, $name, $(cf service $name --guid), $service >> AWS_resource_inventory.csv
        else
            echo $space, $name, $(cf service $name --guid), $service >> temp1.csv
        fi
    done

    # # get list of aws-eks-service service
    service='aws-eks-service'
    aws_eks_service_services=$(cf s | grep $service | awk '{print $1}')
    for name in $aws_eks_service_services
    do 
        echo $space, $name, $(cf service $name --guid), $service >> temp2.csv
    done

done

cat temp1.csv >> AWS_resource_inventory.csv
cat temp2.csv >> AWS_resource_inventory.csv

rm temp1.csv
rm temp2.csv

echo "### Done. Pleaes upload AWS_resource_inventory.csv to 'system inventory' on google drive. ### "