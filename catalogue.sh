#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.sreenu.online

TIMESTAMP=$(date +%F---%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
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

useradd roboshop &>> $LOGFILE

VALIDATE $? "creating roboshop user"

mkdir /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue application zip file"

cd /app 

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping the catalogue file"

npm install  &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying monodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalogue data into Mongodb"