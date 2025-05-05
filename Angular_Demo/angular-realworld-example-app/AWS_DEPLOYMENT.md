# AWS Deployment Guide for Angular RealWorld Example App

This guide provides instructions for deploying the Angular RealWorld Example App to AWS using ECS (Elastic Container Service) with a CI/CD pipeline.

## Architecture Overview

The deployment architecture consists of:

1. **VPC** with public subnets across two availability zones
2. **ECS Cluster** running on Fargate (serverless)
3. **Application Load Balancer** to distribute traffic
4. **ECR Repository** to store Docker images
5. **CI/CD Pipeline** using AWS CodePipeline, CodeBuild, and CodeDeploy

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- GitHub account with access to the repository
- GitHub personal access token with repo and admin:repo_hook permissions

## Deployment Steps

### 1. Prepare Your Environment

Make sure you have the AWS CLI installed and configured with appropriate credentials:

```bash
aws configure
```

### 2. Configure the Deployment Script

Edit the `deploy.sh` script and update the following variables:

- `REGION`: Your preferred AWS region (default: us-east-1)
- `GITHUB_OWNER`: Your GitHub username
- `GITHUB_TOKEN`: Your GitHub personal access token

You can also customize other variables like:
- `ENVIRONMENT_NAME`: Environment name (dev, staging, prod)
- `GITHUB_BRANCH`: The branch to deploy from

### 3. Make the Script Executable

```bash
chmod +x deploy.sh
```

### 4. Run the Deployment Script

```bash
./deploy.sh
```

This script will:
1. Create an S3 bucket for CloudFormation templates
2. Deploy the infrastructure stack (VPC, ECS, ALB, etc.)
3. Store ECS cluster and service names in SSM Parameter Store
4. Deploy the CI/CD pipeline stack

### 5. Monitor the Deployment

You can monitor the deployment progress in the AWS Management Console:

1. CloudFormation stacks: https://console.aws.amazon.com/cloudformation
2. CodePipeline: https://console.aws.amazon.com/codepipeline

### 6. Access Your Application

Once the deployment is complete, you can access your application using the ALB URL provided at the end of the deployment script output.

## CI/CD Pipeline

The CI/CD pipeline consists of three stages:

1. **Source**: Pulls the code from GitHub when changes are pushed
2. **Build**: Builds a Docker image and pushes it to ECR
3. **Deploy**: Updates the ECS service with the new image

## Infrastructure Components

### VPC and Networking
- VPC with CIDR block 10.0.0.0/16
- Two public subnets across different availability zones
- Internet Gateway and route tables

### ECS Cluster and Service
- Fargate launch type (serverless)
- Service auto-scaling based on CPU utilization
- Task definition with 256 CPU units and 512 MB memory

### Application Load Balancer
- Internet-facing ALB
- Health checks on the root path (/)
- HTTP listener on port 80

### Security Groups
- ALB security group allowing inbound HTTP traffic
- ECS security group allowing traffic from the ALB

## Customization

### Scaling Parameters

To adjust the scaling parameters, modify the following in `cloudformation/infrastructure.yaml`:

- `DesiredCount`: Initial number of tasks (default: 2)
- `MaxCount`: Maximum number of tasks for auto-scaling (default: 4)

### Container Resources

To adjust the container resources, modify the `TaskDefinition` in `cloudformation/infrastructure.yaml`:

- `Cpu`: CPU units (default: 256)
- `Memory`: Memory in MB (default: 512)

## Cleanup

To delete all resources created by this deployment:

1. Delete the CI/CD pipeline stack:
```bash
aws cloudformation delete-stack --stack-name dev-angular-cicd
```

2. Delete the infrastructure stack:
```bash
aws cloudformation delete-stack --stack-name dev-angular-infra
```

3. Delete the S3 bucket created for CloudFormation templates (replace with your bucket name):
```bash
aws s3 rb s3://angular-app-deployment-TIMESTAMP --force
```

## Troubleshooting

### Pipeline Failures

If the pipeline fails during the build or deploy stages:

1. Check the CodeBuild logs for build failures
2. Verify that the ECS service can pull the Docker image from ECR
3. Check the ECS service events for deployment failures

### Application Issues

If the application is deployed but not accessible:

1. Verify that the health check is passing in the target group
2. Check the ECS task logs for application errors
3. Verify that the security groups allow traffic to the container port

## Security Considerations

- The ALB is publicly accessible. Consider adding WAF or restricting access if needed.
- The GitHub token is stored in CloudFormation. Consider using AWS Secrets Manager for production.
- The ECR repository has a lifecycle policy to keep only the last 10 images.

## Cost Optimization

- Fargate pricing is based on vCPU and memory resources allocated to your tasks.
- ALB is charged by the hour and by the amount of data processed.
- Consider reducing the `DesiredCount` to 1 for development environments.
- Set up AWS Budgets to monitor and alert on costs.