echo -e "\n------------------------- TEST BEGIN -------------------------"
echo -e "             ${iac_tool} - ${provider} - ${region} - ${execution}"
echo -e "--------------------------------------------------------------\n"

LOCAL=$DIR/executions/${EXEC_DATE}/${iac_tool}/${provider}/${region}/${execution}
mkdir -p $LOCAL

PROVISION_RUN=true
UNPROVISION_RUN=true
COUNT=0
RETRY_COUNT=2
RETRY=false

######## PROVISION ########
while [ $PROVISION_RUN ] && [ $COUNT -le $RETRY_COUNT ]; do
    cd ${DIR}/${iac_tool}/code
    echo -e "Starting provisioning process"
    echo "Starting provisioning process" >> $LOCAL/provision.log
    echo "|-------------------------|-----------------|---------------|--------------|-------------------|" >> ${RESULTS}
    ${DIR}/common/print.sh main ${RESULTS} ${EXEC_DATE} Provision ${iac_tool} ${region} ${DIR}
    echo -e "|-----------------------------------------EXECUTION: ${execution}-----------------------------------------|\n" >> ${RESULTS}
    
    ${DIR}/monitors/test_monitor.sh ${RESULTS} ${DIR} &
    monitor_pid=$!
    $cmd_provision  2>&1 | sed 's/\x1b\[[0-9;]*m//g' >> $LOCAL/provision.log
    kill -9 $monitor_pid
    wait $monitor_pid 2>/dev/null
    sleep 5

    if [ ${iac_tool} == 'terraform' ] && [ "$(cat $LOCAL/provision.log | grep 'Apply complete')" == "" ]; then
        echo -e "Provision Failed"
        echo -e "\n|-----------------------------------------EXECUTION: ${execution}-----------------------------------FAILED|\n" >> $RESULTS
        RETRY=true
    elif [ ${iac_tool} != 'terraform' ] && [ "$(cat $LOCAL/provision.log | grep '"provisioningState": "Succeeded"')" == "" ]; then
        echo -e "Provision Failed"
        echo -e "\n|-----------------------------------------EXECUTION: ${execution}-----------------------------------FAILED|\n" >> $RESULTS
        RETRY=true
    else
        echo -e "Provision successfull"
        echo -e "\n|-----------------------------------------EXECUTION: ${execution}----------------------------------SUCCESS|\n" >> $RESULTS
        PROVISION_RUN=false
        RETRY=false
        break
    fi
    if [ $RETRY ]; then
        if [ $COUNT -eq $RETRY_COUNT ]; then
            echo -e "No more retrys... skipping"
            break
        else
            echo -e "Retrying..."
        fi
        COUNT=$((COUNT + 1))
        source $DIR/$iac_tool/test/cleanup.sh
    fi
done
#############################
sleep 20
COUNT=0
######## UNPROVISION ########
while [ $UNPROVISION_RUN ] && [ $COUNT -le $RETRY_COUNT ]; do
    echo -e "Starting unprovisioning process"
    echo "Starting unprovisioning process" >> $LOCAL/unprovision.log
    echo "|-------------------------|-----------------|---------------|--------------|-------------------|" >> ${RESULTS}
    ${DIR}/common/print.sh main ${RESULTS} ${EXEC_DATE} Unprovision ${iac_tool} ${region} ${DIR}
    echo -e "|-----------------------------------------EXECUTION: ${execution}-----------------------------------------|\n" >> ${RESULTS}
    
    ${DIR}/monitors/test_monitor.sh ${RESULTS} ${DIR} &
    monitor_pid=$!
    $cmd_unprovision  2>&1 | sed 's/\x1b\[[0-9;]*m//g' >> $LOCAL/unprovision.log
    kill -9 $monitor_pid
    wait $monitor_pid 2>/dev/null
    sleep 5
    
    if [ $iac_tool == 'terraform' ] && [ "$(cat $LOCAL/unprovision.log | grep 'Destroy complete')" == "" ]; then
        echo -e "Unprovision Failed"
        echo -e "\n|-----------------------------------------EXECUTION: ${execution}-----------------------------------FAILED|\n" >> $RESULTS
        RETRY=true
    elif [ ${iac_tool} != 'terraform' ] && [ "$(cat $LOCAL/unprovision.log | grep '"provisioningState": "Succeeded"')" == "" ]; then
        echo -e "Unprovision Failed"
        echo -e "\n|-----------------------------------------EXECUTION: ${execution}-----------------------------------FAILED|\n" >> $RESULTS
        RETRY=true
    else
        echo -e "Unprovision successfull"
        echo -e "\n|-----------------------------------------EXECUTION: ${execution}----------------------------------SUCCESS|\n" >> $RESULTS
        UNPROVISION_RUN=false
        RETRY=false
        break
    fi
    if [ $RETRY ]; then
        if [ $COUNT -eq $RETRY_COUNT ]; then
            echo -e "No more retrys... skipping"
            break
        else
            echo -e "Retrying..."
        fi
        COUNT=$((COUNT + 1))
    fi
done
#############################

echo -e "\n--------------------------- TEST END --------------------------"
echo -e "             ${iac_tool} - ${provider} - ${region} - ${execution}"
echo -e "---------------------------------------------------------------\n"