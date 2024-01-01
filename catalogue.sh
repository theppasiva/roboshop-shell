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

dnf module disable nodejs -y

VALIDATE $? "Disabling current nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enabling current nodejs" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing nodejs" &>> $LOGFILE

useradd roboshop

VALIDATE $? "Creating roboshop user" &>> $LOGFILE

mkdir /app

VALIDATE $? "Creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Download catalogue application" &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE $? "Unzipping catalogue" &>> $LOGFILE

npm install 

VALIDATE $? "Installing dependencies" &>> $LOGFILE

# use absloute path, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "Copying catalogue service file" 

systemctl daemon-reload

VALIDATE $? "Catalogue daemon-relod" &>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "Enabling catalogue" &>> $LOGFILE

systemctl start catalogue

VALIDATE $? "Starting catalogue" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo" &>> $LOGFILE

dnf install mongodb-org-shell -y

VALIDATE $? "Installing mongodb client" &>> $LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js


VALIDATE $? "lOADING CATALOGUE DATA INTO MONGODB" &>> $LOGFILE




























