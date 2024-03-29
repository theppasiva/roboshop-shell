#!/bin/bash
AMI=ami-0f3c7d07486cad139 #this keeps on changing
SG_ID=sg-072ef4397e9b05311 #replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z10344631O8SNO4YY2NVK # replace your zone ID
DOMAIN_NAME="shivarampractise.online"

for i in "${INSTANCES[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids sg-072ef4397e9b05311 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
        {
            "Comment": "Creating a record set for cognito endpoint"
            ,"Changes": [{
            "Action"              : "CREATE"
            ,"ResourceRecordSet"  : {
                "Name"              : "'$i'.'$DOMAIN_NAME'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'$IP_ADDRESS'"
                }]
            }
            }]
        }'
done