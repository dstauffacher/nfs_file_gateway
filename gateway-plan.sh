#!/usr/bin/env bash

#stand up the gateway instance, EBS volume, and the S3 back-end
terraform init
terraform get -update
terraform plan

region=$(terraform output region)
export AWS_DEFAULT_REGION=${region}

gateway_name=$(terraform output gateway_name)
if [ $? -eq 1 ] || [ -v "${gateway_name}" ]; then
    echo "The gateway is not in use."
else
    echo "The gateway_name is $gateway_name"
    gateways=$(aws storagegateway list-gateways --query "Gateways[*].{name:GatewayName}" --output text)
    if [ -v "${gateways}" ]; then
        echo "The gateway name $gateway_name is not in use.  Applying will proceed with activation."
    else
        t=$(grep ${gateway_name} <<< "${gateways}")
        if [ -z "${t}" ]; then
            echo "The gateway name $gateway_name is not in use.  Applying will proceed with activation."
        else
            echo "The gateway name $gateway_name is already in use."
        fi;
    fi;
fi;
