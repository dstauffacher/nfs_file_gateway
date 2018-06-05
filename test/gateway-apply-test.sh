#!/usr/bin/env bash
# this script stands up a file gateway ec2 instance and configures it for use
# note the terraform will populate most of the variables used in this script

create_teardown_script ()
{
    # teardown requires deletion of gateway artifact prior to terraform teardown
    # this portion of the script creates the gateway artifact deletion script, should it be needed
    cat << EOF > teardown-${gateway_name}.sh
#!/usr/bin/env bash
# this script tears down the file gateway ec2 instance
aws storagegateway delete-gateway --gateway-arn ${gateway_arn}
echo "storage gateway deletion complete"
aws storagegateway list-gateways
echo "starting terraform destroy"
terraform destroy --force
exit
EOF

    echo "if you want to tear down the infrastructure, run these commands:"
    cat teardown-${gateway_name}.sh
}

#stand up the gateway instance, EBS volume, and the S3 back-end
terraform init
terraform get -update
terraform apply -input=false -auto-approve

#variables from terraform
application=$(terraform output application)
echo "The gateway application is $application"
environment=$(terraform output environment)
echo "The gateway environment is $environment"
role=$(terraform output role)
echo "The gateway role is $role"
line_of_business=$(terraform output line_of_business)
echo "The gateway line_of_business is $line_of_business"
lifespan=$(terraform output lifespan)
echo "The gateway lifespan is $lifespan"
customer=$(terraform output customer)
echo "The gateway customer is $customer"
owner_email=$(terraform output owner_email)
echo "The gateway owner_email is $owner_email"
creator_arn=$(terraform output creator_arn)
echo "The gateway creator_arn is $creator_arn"
region=$(terraform output region)
echo "The gateway region is $region"
gateway_id=$(terraform output gateway_instance_id)
echo "The gateway_id is $gateway_id"
gateway_name=$(terraform output gateway_name)
echo "The gateway_name is $gateway_name"
s3_bucket_arn=$(terraform output s3_bucket_arn)
echo "The s3 bucket arn is $s3_bucket_arn"
ip_address=$(terraform output gateway_ip_address)
echo "The ip_address is $ip_address"
role_arn=$(terraform output role_policy_arn)
echo "The role_arn is $role_arn"
gateway_fqdn=$(terraform output gateway_fqdn)
echo "The gateway_fqdn is $gateway_fqdn"

export AWS_DEFAULT_REGION=${region}

#activate the gateway
echo "waiting for the instance $gateway_id to become ready"
aws ec2 wait instance-status-ok --instance-ids ${gateway_id}
echo "the EC2 instance is ready"

gateways=$(aws storagegateway list-gateways --query "Gateways[*].{name:GatewayName}" --output text)
if [ -v "${gateways}" ]; then
    echo "The gateway name $gateway_name is not in use.  Proceeding with activation."
else
    t=$(grep ${gateway_name} <<< "${gateways}")
    if [ -z "${t}" ]; then
        echo "The gateway name $gateway_name is not in use.  Proceeding with activation."
    else
        gateway_arn=$(aws storagegateway list-gateways --query "Gateways[*].{arn:GatewayARN,name:GatewayName}" --output text | grep ${gateway_name} | awk '{print $1}')
        create_teardown_script

        echo "The gateway name $gateway_name is already in use.  Script will now exit."
        exit
    fi;
fi;

activation_key=$(curl -f -s -S -w '%{redirect_url}' ${ip_address} | grep -oE 'activationKey=[A-Z0-9-]+' | cut -f2 -d=)
echo "the activation_key is $activation_key"
aws storagegateway activate-gateway --activation-key ${activation_key} --gateway-name ${gateway_name} --gateway-region ${region} --gateway-timezone GMT-6:00 --gateway-type FILE_S3
sleep 10  # this is necessary to allow the gateway activation process to complete before attempting to retrieve the gateway_arn value

# gets the gateway_arn and uses that to lookup the volume ID
gateway_arn=$(aws storagegateway list-gateways --query "Gateways[*].{arn:GatewayARN,name:GatewayName}" --output text | grep ${gateway_name} | awk '{print $1}')
volume_id=$(aws storagegateway list-local-disks --gateway-arn ${gateway_arn} --query "Disks[*].{id:DiskId}" --output text)
echo "the volume ID is $volume_id"

# add the gateway cache
echo "adding cache to the gateway"
aws storagegateway add-cache --gateway-arn ${gateway_arn} --disk-id ${volume_id}

# Create the share, attaching to $s3_bucket
echo "creating the nfs file share"
aws storagegateway create-nfs-file-share --client-token ${gateway_name} --gateway-arn ${gateway_arn} --location-arn ${s3_bucket_arn} --default-storage-class S3_STANDARD --role ${role_arn}

# Create the tags
echo "adding tags to the gateway"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=Application,Value="${application}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=CreatorARN,Value="${creator_arn}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=Customer,Value="${customer}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=Environment,Value="${environment}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=GatewayFQDN,Value="${gateway_fqdn}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=Lifespan,Value="${lifespan}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=LineOfBusiness,Value="${line_of_business}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=Name,Value="${gateway_name}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=OwnerEmail,Value="${owner_email}"
aws storagegateway add-tags-to-resource --resource-arn ${gateway_arn} --tags Key=Role,Value="${role}"

create_teardown_script