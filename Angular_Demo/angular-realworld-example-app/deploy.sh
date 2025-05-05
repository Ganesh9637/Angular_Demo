#!/bin/bash
set -e

# Configuration
ENVIRONMENT_NAME="dev"
REGION="us-east-1"  # Change to your preferred region
STACK_NAME="${ENVIRONMENT_NAME}-angular-infra"
CICD_STACK_NAME="${ENVIRONMENT_NAME}-angular-cicd"
ECR_REPOSITORY_NAME="angular-realworld-app"
GITHUB_OWNER=""  # Fill in your GitHub username
GITHUB_REPO="angular-realworld-example-app"
GITHUB_BRANCH="main"  # Change to your branch name
GITHUB_TOKEN=""  # Fill in your GitHub token

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials are not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

# Check if GitHub parameters are provided
if [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}Please provide your GitHub username and token in the script.${NC}"
    exit 1
fi

# Create S3 bucket for CloudFormation templates
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BUCKET_NAME="angular-app-deployment-${TIMESTAMP}"
echo -e "${GREEN}Creating S3 bucket for CloudFormation templates...${NC}"
aws s3 mb s3://${BUCKET_NAME} --region ${REGION}

# Upload CloudFormation templates to S3
echo -e "${GREEN}Uploading CloudFormation templates to S3...${NC}"
aws s3 cp cloudformation/infrastructure.yaml s3://${BUCKET_NAME}/infrastructure.yaml
aws s3 cp cloudformation/cicd-pipeline.yaml s3://${BUCKET_NAME}/cicd-pipeline.yaml

# Deploy infrastructure stack
echo -e "${GREEN}Deploying infrastructure stack...${NC}"
aws cloudformation create-stack \
    --stack-name ${STACK_NAME} \
    --template-url https://${BUCKET_NAME}.s3.amazonaws.com/infrastructure.yaml \
    --parameters ParameterKey=EnvironmentName,ParameterValue=${ENVIRONMENT_NAME} \
                 ParameterKey=ECRRepositoryName,ParameterValue=${ECR_REPOSITORY_NAME} \
    --capabilities CAPABILITY_IAM \
    --region ${REGION}

echo -e "${GREEN}Waiting for infrastructure stack to complete...${NC}"
aws cloudformation wait stack-create-complete --stack-name ${STACK_NAME} --region ${REGION}

# Store ECS cluster and service names in SSM Parameter Store
echo -e "${GREEN}Storing ECS cluster and service names in SSM Parameter Store...${NC}"
ECS_CLUSTER_NAME=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='ECSCluster'].OutputValue" --output text --region ${REGION})
ECS_SERVICE_NAME=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='ECSService'].OutputValue" --output text --region ${REGION})

aws ssm put-parameter \
    --name "/${ENVIRONMENT_NAME}/ECSClusterName" \
    --value "${ECS_CLUSTER_NAME}" \
    --type "String" \
    --overwrite \
    --region ${REGION}

aws ssm put-parameter \
    --name "/${ENVIRONMENT_NAME}/ECSServiceName" \
    --value "${ECS_SERVICE_NAME}" \
    --type "String" \
    --overwrite \
    --region ${REGION}

# Deploy CI/CD pipeline stack
echo -e "${GREEN}Deploying CI/CD pipeline stack...${NC}"
aws cloudformation create-stack \
    --stack-name ${CICD_STACK_NAME} \
    --template-url https://${BUCKET_NAME}.s3.amazonaws.com/cicd-pipeline.yaml \
    --parameters ParameterKey=EnvironmentName,ParameterValue=${ENVIRONMENT_NAME} \
                 ParameterKey=GitHubOwner,ParameterValue=${GITHUB_OWNER} \
                 ParameterKey=GitHubRepo,ParameterValue=${GITHUB_REPO} \
                 ParameterKey=GitHubBranch,ParameterValue=${GITHUB_BRANCH} \
                 ParameterKey=GitHubToken,ParameterValue=${GITHUB_TOKEN} \
                 ParameterKey=ECRRepositoryName,ParameterValue=${ECR_REPOSITORY_NAME} \
    --capabilities CAPABILITY_IAM \
    --region ${REGION}

echo -e "${GREEN}Waiting for CI/CD pipeline stack to complete...${NC}"
aws cloudformation wait stack-create-complete --stack-name ${CICD_STACK_NAME} --region ${REGION}

# Get the load balancer URL
ALB_URL=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='LoadBalancerDNS'].OutputValue" --output text --region ${REGION})

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}Your application will be available at: http://${ALB_URL}${NC}"
echo -e "${YELLOW}Note: It may take a few minutes for the initial deployment to complete.${NC}"