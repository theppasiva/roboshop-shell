#!/bin/bash
AMI=ami-0f3c7d07486cad139 #this keeps on changing
SG_ID=sg-072ef4397e9b05311 #replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
#ZONE_ID=Z104317737D96UJVA7NEF # replace your zone ID
#DOMAIN_NAME="shivarampractise.online "

for i in "${INSTANCES[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCE_TYPE --security-group-ids sg-072ef4397e9b05311 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"

done