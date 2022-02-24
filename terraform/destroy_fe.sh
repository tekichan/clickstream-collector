#!/bin/bash
###
# Shell script to destroy Terraform script
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

# Remove front end and log files
aws $AWS_PROFILE_PART s3 rm s3://$WEBAPP_BUCKET/ --recursive
aws $AWS_PROFILE_PART s3 rm s3://$WEBAPP_BUCKET-log/ --recursive

# applying terraform
cd dev/webapp-hosting
VAR_PART="-var=AWS_REGION=$AWS_REGION"
VAR_PART="${VAR_PART} -var=WEBAPP_STACK=$WEBAPP_STACK"
VAR_PART="${VAR_PART} -var=WEBAPP_BUCKET=$WEBAPP_BUCKET"
terraform destroy ${VAR_PART}

cd $PWD
