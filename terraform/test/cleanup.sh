printf "\n     Initializing Terraform ..."

DIR_BASE=${DIR}/${iac_tool}/code
cd $DIR_BASE

COUNTc=0
RETRY_COUNTc=2
RETRYc=true

# Initialize terraform
terraform init > /dev/null
printf " DONE "

# Run terraform destroy command to cleanup any remaining resources
printf "\n     Cleaning up resources through terraform destroy ..."
while [ $COUNTc -le $RETRY_COUNTc ]; do
    $cmd_unprovision > /dev/null
    # Check exit status of cmd_unprovision
    if [ $? -ne 0 ]; then
        printf "\n     Error: cmd_unprovision failed"
        if [ $RETRYc ]; then
            if [ $COUNTc -eq $RETRY_COUNTc ]; then
                printf "\n     No more retrys... skipping"
            else
                printf "\n     Retrying..."
            fi
            COUNTc=$((COUNTc + 1))
        fi
    else
        printf " DONE "
        break
    fi
done

printf "\n\n"