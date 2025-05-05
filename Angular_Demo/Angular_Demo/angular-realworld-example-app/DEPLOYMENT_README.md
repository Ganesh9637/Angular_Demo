# Angular RealWorld Example App - Deployment Improvements

## Overview

This document explains the improvements made to the deployment process for the Angular RealWorld Example App. The main enhancement is that the `deploy.sh` script now checks for existing infrastructure resources before attempting to create new ones, which prevents unnecessary recreation of resources on subsequent deployments.

## Key Changes

The `deploy.sh` script has been modified to:

1. Check if the infrastructure CloudFormation stack (`${ENVIRONMENT_NAME}-angular-infra`) already exists
2. If the stack exists, update it using CloudFormation change sets instead of trying to create a new one
3. If the stack doesn't exist, create it as before
4. Apply the same logic to the CI/CD pipeline stack (`${ENVIRONMENT_NAME}-angular-cicd`)
5. Handle the case where no updates are needed for existing stacks

## How It Works

### Infrastructure Stack Deployment

The script now follows this process for the infrastructure stack:

1. Check if the stack exists using `aws cloudformation describe-stacks`
2. If the stack doesn't exist, create it using `aws cloudformation create-stack`
3. If the stack exists:
   - Create a change set using `aws cloudformation create-change-set`
   - Check if the change set contains any changes
   - If there are changes, execute the change set to update the stack
   - If there are no changes, delete the change set and continue

### CI/CD Pipeline Stack Deployment

The same logic is applied to the CI/CD pipeline stack:

1. Check if the CI/CD stack exists
2. Create it if it doesn't exist
3. Update it using change sets if it does exist

## Benefits

- **Resource Reuse**: Existing AWS resources are reused rather than recreated
- **Faster Deployments**: Subsequent deployments are faster since they only update what's changed
- **Cost Efficiency**: Prevents unnecessary resource creation and deletion
- **Error Prevention**: Avoids errors that would occur when trying to create resources that already exist

## Usage

The usage of the script remains the same:

```bash
# Make the script executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

## Notes

- The script still requires you to fill in your GitHub username and token
- The script creates a new S3 bucket for each deployment to store CloudFormation templates
- CloudFormation outputs are still stored in SSM Parameter Store for use by the CI/CD pipeline