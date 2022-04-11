#!/bin/bash

# Script designed to test the 


# Formatting console output
red=$'\x1B[31;1m'
yellow=$'\x1B[33;1m'
green=$'\x1B[32;1m'
blue=$'\x1B[34;1m'
blink=$'\x1B[5m'
end=$'\x1B[0m'
bold=$'\x1B[1m'

error=$red
info=$blue
warning=$yellow
correct=$green

function error {
    echo "${error} [ERROR]${end} # ${1}${end}"
}

function warning {
    echo "${warning} [WARN]${end} # ${1}${end}"
}

function info {
    echo "${info} [INFO]${end} # ${1}${end}"
}

function success {
    echo "${correct} [OK]${end} # ${1}${end}"
}

LOCAL_URL=http://localhost:8080
ERROR=0 # Failed tests counter
SUCCESS=0 # Success tests counter

function curlAndTestPost() {

    # Pass a URL and the expected code. If matches, the test passes, if not, if fails.
    URL_TO_CALL=$1
    EXPECTED_CODE=$2

    #Call the scraper service
    C_RESPONSE=$(curl --header "Content-Type: application/json" --request POST --data '{"url": "'"$URL_TO_CALL"'"}' ${LOCAL_URL} --silent --write-out "HTTPSTATUS:%{http_code}")
    
    # Parse the output
    HTTP_BODY=$(echo $C_RESPONSE | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
    HTTP_STATUS=$(echo $C_RESPONSE | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
    C_URL=$(echo $HTTP_BODY | jq --raw-output '.url')
    C_CODE=$(echo $HTTP_BODY | jq --raw-output '.code')
    info "Testing for URL $URL_TO_CALL and code $EXPECTED_CODE"
    # First of all we check if the scraper service returned 201 for the call
    if [[ $HTTP_STATUS == 201 ]]; then
        # Then we can check if the code matches the one expected for the URL passed to the service
        if [[ "$C_CODE" != "$EXPECTED_CODE" ]] || [[ "$C_URL" != "$URL_TO_CALL" ]]; then
            # Not matched, failed test
            error "Expected code $EXPECTED_CODE did not matched received code $C_CODE :("
            error "Expected URL $C_URL did not matched received URL $URL_TO_CALL :)"
            ((++ERROR))
        else
            # Matched, passed test
            echo "Expected code $EXPECTED_CODE matched received code $C_CODE :)"
            echo "Expected URL $C_URL matched received URL $URL_TO_CALL :)"
            ((++SUCCESS))
        fi
    else
        # The scraper service did not answered 201, test failed
        info "The API did not answered 201 as expected, it answered $HTTP_STATUS"
        ((++ERROR))
    fi

}

function curlAndTestGet() {

    # Test the metrics endpoint
    info "Testing the metrics endpoint"
    C_RESPONSE=$(curl --request GET ${LOCAL_URL}/metrics --silent --write-out "HTTPSTATUS:%{http_code}")
    #Parse the response
    HTTP_BODY=$(echo $C_RESPONSE | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
    HTTP_STATUS=$(echo $C_RESPONSE | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
    
    # PRE_METRIC=$( echo $HTTP_BODY | grep $1 )
    # echo "$PRE_METRIC"
    # METRIC=$(IFS=', ' read -r -a array <<< "$PRE_METRIC")

    # echo "${array[0]}"
    # echo "${array[1]}"

    if [[ $HTTP_STATUS == 200 ]]; then
        # Code 200 received, test passed
        echo "/metrics paths is returning the code $HTTP_STATUS as expected "
        echo "Result of the metrics endpoint"
        echo "$HTTP_BODY"
        echo -e "\n"
        ((++SUCCESS))
    else
        # Code other thsn 200, test feiled
        error "/metrics paths is NOT returning the code 200 as expected, is returning $HTTP_STATUS"
        ((++ERROR))
    fi

}

# Testing scraper service
info "Testing scraper service"

for i in {1..3}
do
   curlAndTestPost https://www.google.com 200
done

for i in {1..2}
do
   curlAndTestPost http://phaidra.ai 308
done

for i in {1..4}
do
   curlAndTestPost http://notexist.forsure 0
done

for i in {1..4}
do
   curlAndTestPost https://www.google.com/notexisting 404
done

   curlAndTestGet

if [[ $ERROR -eq 0 ]]; then
    success "$SUCCESS tests passed"
    success "$ERROR tests failed"
    exit 0
else
    error "$SUCCESS tests passed"
    error "$ERROR tests failed"
    exit 1
fi




                                                                                          