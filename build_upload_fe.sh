#!/bin/bash
###
# Shell script to build and upload
# the front end app
###

# Check and determine status of the given stack
function check_stack_status() {
  STACK_STATUS=$(aws cloudformation describe-stacks --region "$1" --stack-name "$2" 2>&1 | jq -M -r ".Stacks[0].StackStatus")
  LAST_STATUS=$?
  if [ $LAST_STATUS -ne 0 ]; then
    echo "error"
  else
    case $STACK_STATUS in
    "CREATE_COMPLETE" | "UPDATE_COMPLETE")
      echo "success"
      ;;
    "ROLLBACK_FAILED" | "ROLLBACK_COMPLETE" | "ROLLBACK_IN_PROGRESS" | "UPDATE_ROLLBACK_COMPLETE" | "UPDATE_ROLLBACK_FAILED" | "CREATE_FAILED" | "UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS" | "UPDATE_ROLLBACK_IN_PROGRESS" | "DELETE_FAILED")
      echo "fail"
      ;;
    *)
      echo "processing"
      ;;
    esac
  fi
}

# Function: Check status until available
loop_check_stack_status() {
  echo "[$(date)] Check cloudformation status..."

  WAIT_TIME=0
  CHECK_INTERVAL=10
  # Timeout Period as 30 mins
  TIMEOUT_PERIOD=1800
  while (( WAIT_TIME < $TIMEOUT_PERIOD )) && [ "$(check_stack_status "$1" "$2")" == "processing" ]; do
    echo "Waited ${WAIT_TIME}s..."
    (( WAIT_TIME=WAIT_TIME+CHECK_INTERVAL ))
    sleep $CHECK_INTERVAL
  done

  STACK_STATUS=$(check_stack_status "$1" "$2")
  if [ $STACK_STATUS == "success" ]; then
    echo "[$(date)] $2 deployment is successful."
  else
    echo "[$(date)] $2 deployment is failed."
    exit -1
  fi
  return 0
}

# show usage
function helptext {
  echo "Usage:"
  echo "-h,  --help				Shows this brief help message"
  echo "-e, --env	       		Specify the environment variable file"
}

# process command arguments
ENV_FILE=.env   # default file name .env
while [[ $# > 1 ]]
do
  key="$1"

  case $key in
    -e|--env)
      ENV_FILE="$2"
      shift # past argument
      ;;
    -h|--help)
      helptext
      exit 0
      ;;
    *)
      helptext
      exit 1
      ;;
  esac
  shift # past argument or value
done

PWD=`pwd`

# Read Environment Variables
while read line; do export $line; done < $ENV_FILE

# Check if AWS Profile exists. 
if [ ! -z "$AWS_PROFILE" ]; then export AWS_PROFILE_PART="--profile=$AWS_PROFILE"; else export AWS_PROFILE_PART=""; fi

# Check if the stack exists
CF_ACTION="describe-stacks"
STACK_INFO=$(aws ${AWS_PROFILE_PART} cloudformation describe-stacks --stack-name ${WEBAPP_STACK} --region ${AWS_REGION} 2>&1)
if grep -q "does not exist" <<< "${STACK_INFO}"; then
  echo "[$(date)] Stack ${WEBAPP_STACK} does not exist in ${AWS_REGION}. It will be created."
  CF_ACTION="create-stack"
else
  echo "[$(date)] Stack ${WEBAPP_STACK} exists in ${AWS_REGION}. It will be updated."
  CF_ACTION="update-stack"
fi

# Create a hosting bucket
aws $AWS_PROFILE_PART cloudformation ${CF_ACTION} --region $AWS_REGION --stack-name $WEBAPP_STACK --template-body file://./cloudformation/webapp-hosting-cf.yaml --parameters ParameterKey=BucketNameParam,ParameterValue=$WEBAPP_BUCKET

# Loop to check status until Cloudformation is done
loop_check_stack_status "$AWS_REGION" "$WEBAPP_STACK"

# Build the webapp
cd react-touchwood
rm -rf build
npm run build

# Upload the built code to S3 bucket
aws $AWS_PROFILE_PART s3 rm s3://$WEBAPP_BUCKET/ --recursive
aws $AWS_PROFILE_PART s3 cp ./build/ s3://$WEBAPP_BUCKET/ --recursive

# Show the Cloudformation result
CF_DOMAIN=$(aws $AWS_PROFILE_PART cloudformation describe-stacks --region $AWS_REGION --stack-name $WEBAPP_STACK 2>&1 |jq -M -r ".Stacks[0].Outputs[0].OutputValue")
echo "[$(date)] CloudFront ${CF_DOMAIN} is created."

cd $PWD
