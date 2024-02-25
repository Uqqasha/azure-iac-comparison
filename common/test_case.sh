echo -e "\n------------------------- TEST BEGIN -------------------------"
echo -e "             ${iac_tool} - ${provider} - ${region} - ${execution}"
echo -e "--------------------------------------------------------------\n"

LOCAL=$DIR/executions/${EXEC_DATE}/${iac_tool}/${provider}/${region}/${execution}
mkdir -p $LOCAL

PROVISION_RUN=true
UNPROVISION_RUN=true

cd ${DIR}/${iac_tool}/code

######## PROVISION ########
while [ $PROVISION_RUN ]; do
    echo -e "Starting provisioning process"
    echo "Starting provisioning process" >> $LOCAL/provision.log
    echo "|---------------------|-------------|-----------|----------|---------------|-----------|------------|-----------|--------|" >> ${RESULTS}
    ${DIR}/monitors/test_monitor.sh ${RESULTS} ${EXEC_DATE} Provision ${iac_tool} azure ${region} ${execution} ${DIR} &
    monitor_pid=$!
    $cmd_provision  2>&1 | sed 's/\x1b\[[0-9;]*m//g' >> $LOCAL/provision.log
    kill -9 $monitor_pid &> /dev/null

    if [ ${iac_tool} == 'terraform' ] && [ "$(cat $LOCAL/provision.log | grep 'Apply complete')" == "" ]; then
        echo -e "Provision Failed"
        echo "|---------------------|-------------|-----------|----------|---------------|   FAILED  |------------|-----------|--------|" >> $RESULTS
        break
    elif [ ${iac_tool} != 'terraform' ] && [ "$(cat $LOCAL/provision.log | grep '"provisioningState": "Succeeded"')" == "" ]; then
        echo -e "Provision Failed"
        echo "|---------------------|-------------|-----------|----------|---------------|   FAILED  |------------|-----------|--------|" >> $RESULTS
        break
    else
        echo -e "Provision successfull"
        echo "|---------------------|-------------|-----------|----------|---------------|  SUCCESS  |------------|-----------|--------|" >> $RESULTS
        PROVISION_RUN=false
        break
    fi
done
#############################
sleep 20
######## UNPROVISION ########
while [ $UNPROVISION_RUN ]; do
    echo -e "Starting unprovisioning process"
    echo "Starting unprovisioning process" >> $LOCAL/unprovision.log
    echo "|---------------------|-------------|-----------|----------|---------------|-----------|------------|-----------|--------|" >> ${RESULTS}
    ${DIR}/monitors/test_monitor.sh ${RESULTS} ${EXEC_DATE} Unprovision ${iac_tool} azure ${region} ${execution} ${DIR} &
    monitor_pid=$!
    $cmd_unprovision  2>&1 | sed 's/\x1b\[[0-9;]*m//g' >> $LOCAL/unprovision.log
    kill -9 $monitor_pid &> /dev/null

    if [ $iac_tool == 'terraform' ] && [ "$(cat $LOCAL/unprovision.log | grep 'Destruction complete')" == "" ]; then
        echo -e "Unprovision Failed"
        echo "|---------------------|-------------|-----------|----------|---------------|   FAILED  |------------|-----------|--------|" >> $RESULTS
    elif [ ${iac_tool} != 'terraform' ] && [ "$(cat $LOCAL/unprovision.log | grep '"provisioningState": "Succeeded"')" == "" ]; then
        echo -e "Unprovision Failed"
        echo "|---------------------|-------------|-----------|----------|---------------|   FAILED  |------------|-----------|--------|" >> $RESULTS
    else
        echo -e "Unprovision successfull"
        echo "|---------------------|-------------|-----------|----------|---------------|  SUCCESS  |------------|-----------|--------|" >> $RESULTS
        UNPROVISION_RUN=false
        break
    fi
done
#############################

echo -e "\n--------------------------- TEST END --------------------------"
echo -e "             ${iac_tool} - ${provider} - ${region} - ${execution}"
echo -e "---------------------------------------------------------------\n"