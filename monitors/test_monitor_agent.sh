PREFIX=/tmp/temp_

echo $((`cat ${PREFIX}count` + 1)) > ${PREFIX}count

# Memory
MEM_USED=$(bc -l <<<"`python3 -c 'import psutil; print(psutil.virtual_memory().used)'`-`cat ${PREFIX}mem_initial`")
echo $(bc -l <<<"${MEM_USED}+`cat ${PREFIX}mem_amount`") > ${PREFIX}mem_amount

# Log
MEM=$(bc -l <<<"`cat ${PREFIX}mem_amount`/`cat ${PREFIX}count`/1024")

#Duration
SPENT=$(bc -l <<<"(`date +%s`-`cat ${PREFIX}time_init`)/60")

if [ $3 == "Provision" ]; then
    if [ $4 == "terraform" ]; then
        echo "| $2 | $3   | $4 | $5    | $6 |     $7     | $(date +%s) | $(printf '%.*f\n' 2 ${SPENT})      | $(printf '%.*f\n' 2 ${MEM}) |" >> $1
    elif [ $4 == "ARM" ]; then
        echo "| $2 | $3   |    $4    | $5    | $6 |     $7     | $(date +%s) | $(printf '%.*f\n' 2 ${SPENT})      | $(printf '%.*f\n' 2 ${MEM}) |" >> $1
    else 
        echo "| $2 | $3   |   $4   | $5    | $6 |     $7     | $(date +%s) | $(printf '%.*f\n' 2 ${SPENT})      | $(printf '%.*f\n' 2 ${MEM}) |" >> $1
    fi
else
    if [ $4 == "terraform" ]; then
        echo "| $2 | $3 | $4 | $5    | $6 |     $7     | $(date +%s) | $(printf '%.*f\n' 2 ${SPENT})      | $(printf '%.*f\n' 2 ${MEM}) |" >> $1
    elif [ $4 == "ARM" ]; then
        echo "| $2 | $3 |    $4    | $5    | $6 |     $7     | $(date +%s) | $(printf '%.*f\n' 2 ${SPENT})      | $(printf '%.*f\n' 2 ${MEM}) |" >> $1
    else 
        echo "| $2 | $3 |   $4   | $5    | $6 |     $7     | $(date +%s) | $(printf '%.*f\n' 2 ${SPENT})      | $(printf '%.*f\n' 2 ${MEM}) |" >> $1
    fi
fi