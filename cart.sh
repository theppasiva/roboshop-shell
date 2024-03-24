#!bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

id roboshop # if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "Creating roboshop user"
else
    echo -e "roboshop user already exist $Y Skipping $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory" 

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Download cart application" 

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unziping cart" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

# use absloute path, because cart.service exists there
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Copying cart service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Catalocartgue daemon-relod" 

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enabling cart" 

systemctl start cart &>> $LOGFILE

VALIDATE $? "Starting cart" 

 




























