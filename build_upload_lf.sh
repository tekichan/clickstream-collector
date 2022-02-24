#!/bin/bash
###
# Shell script to build and upload
# the Lambda function
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

# Package Lambda function code
cd kstream-collector
zip -r9 ../poc-kstream-collector.zip *
cd ..

# Upload the package to S3 bucket
aws $AWS_PROFILE_PART s3 cp poc-kstream-collector.zip s3://$LAMBDA_CODE_BUCKET/$LAMBDA_CODE_PATH/

# Check if the stack exists
CF_ACTION="describe-stacks"
STACK_INFO=$(aws ${AWS_PROFILE_PART} cloudformation describe-stacks --stack-name ${KSTREAM_STACK} --region ${AWS_REGION} 2>&1)
if grep -q "does not exist" <<< "${STACK_INFO}"; then
  echo "[$(date)] Stack ${KSTREAM_STACK} does not exist in ${AWS_REGION}. It will be created."
  CF_ACTION="create-stack"
else
  echo "[$(date)] Stack ${KSTREAM_STACK} exists in ${AWS_REGION}. It will be updated."
  CF_ACTION="update-stack"
fi

# Create a click-stream collector infrastructure
CF_CAPABILITIES="CAPABILITY_IAM  CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND"
CF_PARAMS="ParameterKey=CodeS3Bucket,ParameterValue=${LAMBDA_CODE_BUCKET}"
CF_PARAMS="${CF_PARAMS} ParameterKey=LambdaCodeFolder,ParameterValue=${LAMBDA_CODE_PATH}"
CF_PARAMS="${CF_PARAMS} ParameterKey=VpcId,ParameterValue=${VPC_ID}"
CF_PARAMS="${CF_PARAMS} ParameterKey=VpcELBSubnets,ParameterValue=\"${ELB_SUBNETS}\""
CF_PARAMS="${CF_PARAMS} ParameterKey=DataDestS3Bucket,ParameterValue=${DATA_BUCKET}"
CF_PARAMS="${CF_PARAMS} ParameterKey=DataDestS3Prefix,ParameterValue=${DATA_PREFIX}"
aws $AWS_PROFILE_PART cloudformation ${CF_ACTION} --region $AWS_REGION --stack-name $KSTREAM_STACK --template-body file://./cloudformation/kstream-collector-cf.yaml  --parameters ${CF_PARAMS} --capabilities ${CF_CAPABILITIES}

# Loop to check status until Cloudformation is done
loop_check_stack_status "$AWS_REGION" "$KSTREAM_STACK"

# Write ELB Domain into the front end env file
ELB_DOMAIN=$(aws $AWS_PROFILE_PART cloudformation describe-stacks --region $AWS_REGION --stack-name $KSTREAM_STACK 2>&1 |jq -M -r ".Stacks[0].Outputs[0].OutputValue")
echo "REACT_APP_SITE_DOMAIN=http://${ELB_DOMAIN}">./react-touchwood/.env.production.local

echo "[$(date)] ELB ${ELB_DOMAIN} is created."

cd $PWD
