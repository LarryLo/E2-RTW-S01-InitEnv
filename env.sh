#!/bin/bash

NODEJS_DIR=docker/e2rtw-s01
NODEJS_TMP_DIR=$NODEJS_DIR-tmp

## STEP 2
docker pull toke/mosquitto

## STEP 3
mkdir -p docker/e2rtw-mqtt/data 
docker stop e2rtw-mqtt
docker stop e2rtw-s01
docker rm e2rtw-mqtt
docker rm e2rtw-s01
docker run -p 1883:1883 -p 9001:9001 --name e2rtw-mqtt -v $(pwd)/docker/e2rtw-mqtt/data:/mqtt/data:ro -d toke/mosquitto
docker ps -a
mkdir -p $NODEJS_TMP_DIR

## STEP 4.1
cat <<EOL >$NODEJS_TMP_DIR/package.json

{
    "name": "e2rtws01",
    "version": "1.0.0",
    "description": "Realtime web application - e2rtws01", "author": "Erhwen Kuo ",
    "main": "server.js",
    "scripts": {
        "start": "node server.js"
    },
    "dependencies": {
        "express": "^4.13.3"
    }
}
EOL


## STEP 4.2
cat <<EOL >$NODEJS_TMP_DIR/server.js
// "Express.js"
const express = require('express'); 
//   tcp port
const PORT = 8080;
//   Express instance
const app = express();
// "public" 
app.use(express.static('public')); 
//   http get
app.get('/', function (req, res) {
    res.send('Hello world\n');
});
// tcp port request
app.listen(PORT);
//
console.log('Running on http://localhost:' + PORT);
EOL

## STEP 4.3
cat <<EOL >$NODEJS_TMP_DIR/Dockerfile
#   Docker Image 
FROM node:argon
# app
RUN mkdir -p /usr/src/app
#
WORKDIR /usr/src/app
# package.json
COPY package.json /usr/src/app/
# app
RUN npm install
#
COPY . /usr/src/app
# container
EXPOSE 8080
# container
CMD [ "npm", "start" ]
EOL

## STEP 4.4
docker build -t eighty20/e2rtws01 $NODEJS_TMP_DIR

docker images eighty20/e2rtws0

## STEP 4.5
mkdir -p $NODEJS_DIR/public
docker run -p 8080:8080 --name e2rtw-s01 -v $(pwd)/docker/e2rtw-s01/public:/usr/src/app/public:rw -d eighty20/e2rtws01 

## STEP 4.6
curl localhost:8080

## STEP 4.7
docker-machine ip default
curl $(docker-machine ip default):8080

## STEP 5
curl -o $NODEJS_DIR/public/e2-rtw-s01.zip http://eighty20.cc/apps/e2-rtw-v01/present/e2-rtw-s01-env/assets/files/e2-rtw-s01.zip 
unzip $NODEJS_DIR/public/e2-rtw-s01.zip -d $NODEJS_DIR/public
