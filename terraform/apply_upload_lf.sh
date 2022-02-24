#!/bin/bash
###
# Shell script to apply Terraform scripts
# and upload the Lambda function
###

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
cd ../kstream-collector
zip -r9 ../poc-kstream-collector.zip *

# Upload the package to S3 bucket
cd ..
aws $AWS_PROFILE_PART s3 cp poc-kstream-collector.zip s3://$LAMBDA_CODE_BUCKET/$LAMBDA_CODE_PATH/

# Apply Terraform scripts
cd terraform/dev/kstream-collector
VAR_PART="-var AWS_REGION=$AWS_REGION"
VAR_PART="${VAR_PART} -var KSTREAM_STACK=$KSTREAM_STACK"
VAR_PART="${VAR_PART} -var LAMBDA_CODE_BUCKET=$LAMBDA_CODE_BUCKET"
VAR_PART="${VAR_PART} -var LAMBDA_CODE_PATH=$LAMBDA_CODE_PATH"
VAR_PART="${VAR_PART} -var VPC_ID=$VPC_ID"
VAR_PART="${VAR_PART} -var ELB_SUBNETS=$ELB_SUBNETS"
VAR_PART="${VAR_PART} -var DATA_BUCKET=$DATA_BUCKET"
VAR_PART="${VAR_PART} -var DATA_PREFIX=$DATA_PREFIX"

terraform apply -auto-approve $VAR_PART

ELB_DOMAIN=$(terraform output -raw alb_dns)
echo "REACT_APP_SITE_DOMAIN=http://${ELB_DOMAIN}">../../../react-touchwood/.env.production.local

echo "[$(date)] ELB ${ELB_DOMAIN} is created."

cd $PWD
