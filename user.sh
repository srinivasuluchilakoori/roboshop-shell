#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F---%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if  [ $ID -ne 0 ]
then
    echo -e "ERROR:: $R Please run the script with root access $N"
    exit 1
else
    echo -e "$G you are root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling current nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs:18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exists $Y skipping $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user application zip file"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping the user file"

npm install  &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enabling user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying monodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host mongo.sreenu.online </app/schema/user.js &>> $LOGFILE

VALIDATE $? "loading user data into Mongodb"