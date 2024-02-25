#!/bin/bash

# Bootstraps deployment with pre-requisites

# Functions

usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}

# Main

printf "     Bootstraping deployment with pre-requisites ...\n"

## Validate Subscription ID
subscription_id=$(az account list --only-show-errors --query "[? isDefault]|[0].id" --output tsv)
if [ -z $subscription_id ]; then
    printf "Unable to retrieve Azure subscription details. Please run 'az login' first.\n"
    usage
else
    printf "          Azure Subscription ID:    $subscription_id\n"
fi

# Validate Subscription Name
subscription_name=$(az account list --query "[?id=='$subscription_id'].name" --output tsv)
if [ -n "$subscription_name" ]; then 
    printf "          Azure Subscription:       '$subscription_name'...\n"
else
    printf "Invalid subscription id '$subscription_id'.\n"
    usage
fi

## Get Tenant ID
default_aad_tenant_id=$(az account show --query tenantId --output tsv)
printf "          Azure Tenant ID:          $default_aad_tenant_id\n"

## Verify Terraform Pre-requisites
if [ $execution -eq 1 ]; then
    arm_client_id=''
    arm_client_secret=''
    ## Validate arm_client_id
    if [ -z "$arm_client_id" ]; then
        printf "arm_client_id is required.\n"
        usage
    else
        printf "          Azure App ID:             $arm_client_id\n"
    fi

    ## Validate service principal
    arm_client_display_name=$(az ad sp show --id $arm_client_id --query "appDisplayName" --output tsv)
    if [ -n "$arm_client_display_name" ]; then 
        printf "          Azure Service Principal:  '$arm_client_display_name'...\n"
    else
        printf "Invalid service principal AppId '$arm_client_id'...\n"
        usage
    fi

    ## Get Azure Service Principal Object ID
    arm_client_object_id=$(az ad sp show --id $arm_client_id --query "id" --output tsv)

    ## Validate TF_VAR_arm_client_secret
    if [ -z "$TF_VAR_arm_client_secret" ]; then
        printf "Environment variable 'TF_VAR_arm_client_secret' must be set.\n"
        usage
    else
        printf "          Azure Client Secret:      set\n"
    fi

    ## Setting Object ID for Azure CLI signed in user
    owner_object_id=$(az account get-access-token --query accessToken --output tsv | tr -d '\n' | python3 -c "import jwt, sys; print(jwt.decode(sys.stdin.read(), algorithms=['RS256'], options={'verify_signature': False})['oid'])")

    # Populating terraform.tfvars file
    printf "\n          Populating terraform.tfvars file ..."
    terraform_tfvars=${DIR}/terraform/code/terraform.tfvars
    if [ "$(cat $terraform_tfvars | grep 'aad_tenant_id')" != "" ]; then
        printf "\n               terraform.tfvars already contains 'aad_tenant_id'. Skipping population."
    else
        printf "\n\naad_tenant_id                            = \"$default_aad_tenant_id\"\n"   >> $terraform_tfvars
        printf "subscription_id                          = \"$subscription_id\"\n"             >> $terraform_tfvars
        printf "arm_client_id                            = \"$arm_client_id\"\n"               >> $terraform_tfvars
        printf "owner_object_id                          = \"$owner_object_id\"\n"             >> $terraform_tfvars
        printf "arm_client_object_id                     = \"$arm_client_object_id\"\n"        >> $terraform_tfvars

        printf " Done"
    fi

    # Populating ARM parameters file
    printf "\n          Populating ARM parameters file   ..."

    jq --arg key1 "ownerObjectId" --arg value1 "$owner_object_id" \
       --arg key2 "armClientObjectId" --arg value2 "$arm_client_object_id" \
       '.parameters += { ($key1): { "value": $value1 }, ($key2): { "value": $value2 } }' \
        ${DIR}/ARM/code/01-vnet-shared.parameters.json > temp.json && \
    mv temp.json ${DIR}/ARM/code/01-vnet-shared.parameters.json

    printf " Done"

    # Populating Bicep parameters file
    printf "\n          Populating bicep parameters file ..."
    bicepparam=${DIR}/bicep/code/*.bicepparam
    if [ "$(cat $bicepparam | grep 'ownerObjectId')" != "" ]; then
        printf "\n               .bicepparam already contains 'ownerObjectId'. Skipping population."
    else
        printf "\nparam ownerObjectId = \'$owner_object_id\'\n" >> $bicepparam
        printf "param armClientObjectId = \'$arm_client_object_id\'\n" >> $bicepparam

        printf " Done\n"
    fi
fi

printf "\n\n     Bootstrapping COMPLETE \n\n"
printf "     --------------------     \n"