#!bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.shivarampractise.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .... $R FAILED$N"
        exit 1
    else
        echo -e "$2 .......$G Success$N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR: please run this script with root access $N"
    exit 1
else
    echo "you are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling current nodejs:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs:18" 

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "Creating roboshop user"
else
    echo -e "roboshop user already exist $Y Skipping $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Download catalogue application" 

cd /app 

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping catalogue" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

# use absloute path, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Copying catalogue service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Catalogue daemon-relod" 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enabling catalogue" 

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client" 

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE


VALIDATE $? "lOADING CATALOGUE DATA INTO MONGODB" 




























