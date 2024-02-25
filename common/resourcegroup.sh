## Create Resource Group
printf "\n     Creating Resource Group ...\n"
resource_group_name="RG-$region-$iac_tool-$execution"
location=$region

subscription_id=$(az account list --only-show-errors --query "[? isDefault]|[0].id" --output tsv)
if [ -z $subscription_id ]; then
    printf "Unable to retrieve Azure subscription details. Please run 'az login' first.\n"
    usage
else
    printf "          Azure Subscription ID:    $subscription_id\n"
fi

resource_group_id=$(az group list --subscription $subscription_id --query "[?name == '$resource_group_name'] | [0].id" --output tsv)
if [ -n "$resource_group_id" ]; then
    printf "          Found resource group:    $resource_group_name\n"
else
    printf "          Creating resource group '$resource_group_name'...\n"
    az group create \
        --subscription $subscription_id \
        --name $resource_group_name \
        --location $location
fi