#!/bin/bash

LOGDIR=/tmp
SCRIPT_NAME=$0
DATE=$(date +%F:%H:%M:%S)
LOGFILE=$LOGDIR/$SCRIPT_NAME-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
VALIDATE(){
    if [ $1 -eq 0 ];
    then
        echo "$2 ... $G SUCCESS $N"
    else
        echo "$2 ... $R ERROR $N"
        exit 1
    fi
}
USERID=$(id -u)
if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR : Please run this script as a ROOT user $N"
    exit 1
else
    cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
    VALIDATE $1 "Setup the MongoDB repo file"

    yum install mongodb-org -y &>> $LOGFILE
    VALIDATE $1 "Install MongoDB"

    systemctl enable mongod &>> $LOGFILE
    VALIDATE $1 "enable mongod"

    systemctl start mongod &>> $LOGFILE
    VALIDATE $1 "start mongod"

    sed -i "s/127.0.0.10.0.0.0/g" &>> $LOGFILE
    VALIDATE $1 "Update listen address from 127.0.0.1 to 0.0.0.0"

    systemctl restart mongod &>> $LOGFILE
    VALIDATE $1 "Restart the service"
fi