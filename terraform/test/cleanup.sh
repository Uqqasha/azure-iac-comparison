printf "\n     Initializing Terraform ..."

DIR_BASE=${DIR}/${iac_tool}/code
cd $DIR_BASE

# Initialize terraform
terraform init > /dev/null
printf " DONE "

# Run terraform destroy command to cleanup any remaining resources
printf "\n     Cleaning up resources through terraform destroy ..."
$cmd_unprovision > /dev/null
# Check exit status of cmd_unprovision
if [ $? -ne 0 ]; then
    echo "Error: cmd_unprovision failed"
    exit 1
fi
printf " DONE "

printf "\n\n     --------------------     \n"