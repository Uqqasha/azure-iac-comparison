#!/bin/bash
DIR=$(pwd)

# IaC Tools
iac_tools='terraform'

# Provider
provider='azure'

# Regions
azure_region='SwedenCentral'

echo -e "------------------------- STARTING TESTS ------------------------- \n"

EXEC_DATE=$(date +%Y-%m-%d-%H-%M-%S)
mkdir -p ${DIR}/executions/${EXEC_DATE}
RESULTS=${DIR}/executions/${EXEC_DATE}/results
echo "| Date                | Operation   |   Tool    | Provider | Region        | Execution | Timestamp  | Duration  | Memory |" > ${RESULTS}

test_executions=1
execution=1

while [ $execution -le $test_executions ]; do
    if [ $execution -eq 1 ]; then
        source $DIR/common/bootstrap.sh
    fi
    for iac_tool in $iac_tools; do
        for region in $azure_region; do
            source $DIR/common/resourcegroup.sh
            source $DIR/$iac_tool/test/commands.sh
            source $DIR/$iac_tool/test/cleanup.sh
            source $DIR/common/test_case.sh
        done
    done
    execution=$((execution + 1))
done