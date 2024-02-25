printf "\n     Cleaning up ARM ...\n"

DIR_BASE=${DIR}/${iac_tool}/code
cd $DIR_BASE

$cmd_unprovision > /dev/null

printf "\n     --------------------     \n"