#!/bin/bash


#API address
API="$1/api_jsonrpc.php"

#Name of the new host is passed as the first argument
HOSTNAME=$2

#Retrieving address of the host
IP=$(ip -4 address | awk 'NR == 8{print$2}' | cut -d/ -f1)

#Logging as Admin user and retrieving authentication token 
AUTH_TOKEN=$(echo $(curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"user.login\", \
    \"params\": { \
        \"user\": \"Admin\", \
        \"password\": \"zabbix\" \
    }, \
    \"id\": 1 \
}" $API) | cut -d'"' -f 8)

#Retrieving information about a host with the same name if it exists
HOST_RESPONSE=$(curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"host.get\", \
    \"params\": { \
        \"filter\": { \
            \"host\": [ \
            	\"$HOSTNAME\"
            ] \
        } \
    }, \
    \"auth\": \"$AUTH_TOKEN\", \
    \"id\": 1 \
}" $API)


#Function for creating new host
host_create(){
#Retrieving "Linux servers" group id
GROUP_ID=$( echo $(curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"hostgroup.get\", \
    \"params\": { \
        \"output\": \"extend\", \
        \"filter\": { \
            \"name\": [ \
                \"Linux servers\" \
            ] \
        } \
    }, \
    \"auth\": \"$1\", \
    \"id\": 1 \
}" $4) | cut -d'"' -f 10)

#Retrieving "OS Linux" template id
TEMPLATE_ID=$( echo $(curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"template.get\", \
    \"params\": { \
        \"output\": \"extend\", \
        \"filter\": { \
            \"host\": [ \
                \"Template OS Linux\" \
            ] \
        } \
    }, \
    \"auth\": \"$1\", \
    \"id\": 1 \
}" $4)  | cut -d'"' -f 130)

#Creating a new host
curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"host.create\", \
    \"params\": { \
        \"host\": \"$2\", \
        \"interfaces\": [ \
            { \
                \"type\": 1, \
                \"main\": 1, \
                \"useip\": 1, \
                \"ip\": \"$3\", \
                \"dns\": \"\", \
                \"port\": \"10050\" \
            } \
        ], \
        \"groups\": [ \
            { \
                \"groupid\": \"$GROUP_ID\" \
            } \
        ], \
        \"templates\": [ \
            { \
                \"templateid\": \"$TEMPLATE_ID\" \
            } \
        ] \
    }, \
    \"auth\": \"$1\", \
    \"id\": 1 \
}" $4
}

#Function for updating existing host
host_update(){
#Retrieving interface id
INTERFACE_ID=$(echo $(curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"hostinterface.get\", \
    \"params\": { \
        \"output\": \"extend\", \
        \"hostids\": $2 \
    }, \
    \"auth\": \"$1\", \
    \"id\": 1 \
}" $4) | cut -d'"' -f 10 )

#Updating interface
curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"hostinterface.update\", \
    \"params\": { \
        \"interfaceid\": $INTERFACE_ID, \
        \"ip\": \"$3\", \
        \"port\": 10050 \
    }, \
    \"auth\": \"$1\", \
    \"id\": 1 \
}" $4

#Updating host
curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"host.update\", \
    \"params\": { \
        \"hostid\": \"$2\", \
        \"status\": 0
    }, \
    \"auth\": \"$1\", \
    \"id\": 1 \
}" $4
}

#if host exists it will be updated, otherwise it will be created
if [[ $HOST_RESPONSE == *"hostid"* ]]
then
#Retrieving host id if host exists
HOST_ID=$(echo $HOST_RESPONSE | cut -d'"' -f 10)
host_update $AUTH_TOKEN $HOST_ID $IP $API
else
host_create $AUTH_TOKEN $HOSTNAME $IP $API
fi


#Logging out
curl -k -s -H 'Content-Type: application/json-rpc' -d "{ \
    \"jsonrpc\": \"2.0\", \
    \"method\": \"user.logout\", \
    \"params\": [], \
    \"id\": 1, \
    \"auth\": \"$AUTH_TOKEN\" \
}" $API

