printf "\n     Cleaning up Bicep ...\n"

DIR_BASE=${DIR}/${iac_tool}/code
cd $DIR_BASE

$cmd_unprovision > /dev/null 2>&1

printf "\n     --------------------     \n"