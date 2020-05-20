#!/bin/bash

# from: https://gist.github.com/mdjnewman/b9d722188f4f9c6bb277a37619665e77

REGION=us-east-2
STACK_NAME=zep-flink-vpc-stack1

if ! aws cloudformation describe-stacks --region $REGION --stack-name $STACK_NAME ; then

    echo -e "\nStack does not exist; creating stack for VPC..."
    aws cloudformation create-stack \
    --region $REGION \
    --stack-name $STACK_NAME \
    --template-body file://zep-flink-vpc.yaml

fi

# waiting for stack creation to complete...
echo -e "\nWaiting for stack creation to complete..."
aws cloudformation wait stack-create-complete \
    --region $REGION \
    --stack-name $STACK_NAME
echo -e "Stack creation complete"