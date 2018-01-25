echo 
echo "Not working.."

DOWNLOAD_URL=
LOGIN_URL=https://developers.redhat.com/auth/realms/rhd/protocol/openid-connect/auth?client_id=web&response_mode=fragment&response_type=code
USER=eryan.ariobowo
PASS=

echo 
echo "---> Download Red Hat CDK (Minishift)"

#curl --user $USER:$PASS --cookie-jar ./tmp-cookies $LOGIN_URL 
#curl --cookie ./tmp-cookies $DOWNLOAD_URL 

curl -b cookies.txt -c cookies.txt --data "username=$USER&password=$PASS" https://developers.redhat.com/auth/realms/rhd/login-actions/authenticate?code=7OMW0uA0LRMyUbYZLv2jn4RkkBPqBJBdoFV5_JMU-O0.4523feb0-205c-4421-9042-021edbeccf39&execution=d9171cf1-2ffd-4d0a-9f56-d1e828b8546f0

curl --cookie cookies.txt https://developers.redhat.com/download-manager/file/cdk-3.1.1-1-minishift-linux-amd64
rm -f ./temp-cookies
