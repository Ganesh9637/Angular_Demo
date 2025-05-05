# AWS CloudFormation Templates for Angular RealWorld Example App

This directory contains CloudFormation templates for deploying the Angular RealWorld Example App to AWS ECS.

## Files

- `infrastructure.yaml`: Creates the core infrastructure including VPC, ECS Cluster, ALB, and ECR Repository
- `cicd-pipeline.yaml`: Creates the CI/CD pipeline using AWS CodePipeline, CodeBuild, and CodeDeploy

## Deployment

To deploy these templates, use the `deploy.sh` script in the root directory of the project. The script will:

1. Create an S3 bucket for CloudFormation templates
2. Deploy the infrastructure stack
3. Store ECS cluster and service names in SSM Parameter Store
4. Deploy the CI/CD pipeline stack

For detailed instructions, see the [AWS Deployment Guide](../AWS_DEPLOYMENT.md).

## Infrastructure Architecture

![AWS Architecture](https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/containerized-microservices-ecs-fargate-ra.4c6ff3fed1466e04f38726f9d9cb3e825da97df7.png)

The architecture includes:

- VPC with public subnets across two availability zones
- ECS Cluster running on Fargate (serverless)
- Application Load Balancer to distribute traffic
- ECR Repository to store Docker images
- Auto-scaling based on CPU utilization

## CI/CD Pipeline

The CI/CD pipeline consists of three stages:

1. **Source**: Pulls the code from GitHub when changes are pushed
2. **Build**: Builds a Docker image and pushes it to ECR
3. **Deploy**: Updates the ECS service with the new image

## Customization

To customize the deployment, modify the parameters in the CloudFormation templates or update the `deploy.sh` script with your preferred values.