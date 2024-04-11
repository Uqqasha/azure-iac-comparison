PREFIX=/tmp/temp_

echo $((`cat ${PREFIX}count` + 1)) > ${PREFIX}count

## Memory ##
MEM_USED=$(bc -l <<<"`free -b | grep Mem | awk '{print $3}'`-`cat ${PREFIX}mem_initial`")
echo $(bc -l <<<"${MEM_USED}+`cat ${PREFIX}mem_amount`") > ${PREFIX}mem_amount

## CPU ##
CPU=$(bc -l <<<"100-`mpstat | grep all | awk '{print $12}'`")
echo $(bc -l <<<"${CPU}+`cat ${PREFIX}cpu_amount`") > ${PREFIX}cpu_amount

## Disk IO ##
# Get current disk I/O statistics
stats=$(iostat -dy 1 1 | awk '/sda/ {print $2,$6,$7}')
# Extract values for tps, kB_read, and kB_write from stats
tps=$(echo "$stats" | awk '{print $1}')
kb_read=$(echo "$stats" | awk '{print $2}')
kb_write=$(echo "$stats" | awk '{print $3}')
# Add current values to totals
echo $(bc -l <<<"${tps}+`cat ${PREFIX}tps`") > ${PREFIX}tps
echo $(bc -l <<<"${kb_read}+`cat ${PREFIX}io_read`") > ${PREFIX}io_read
echo $(bc -l <<<"${kb_write}+`cat ${PREFIX}io_write`") > ${PREFIX}io_write

## Network ##
NET=$(iftop -t -p -s 1 2>/dev/null | grep "Total send and" | awk -F' ' '{print $6}')
# Extract the numeric value from the output
numeric_value=$(echo "$NET" | grep -o '[0-9]*\(\.[0-9]\+\)\?')
# Extract the unit (b, Kb, Mb) from the output
unit=$(echo "$NET" | grep -o '[^0-9\.]*')
# Convert to bytes
if [ $unit == "Kb" ]; then
    NET=$(echo "${numeric_value}*1024" | bc)
elif [ $unit == "Mb" ]; then
    NET=$(echo "${numeric_value} * 1024 * 1024" | bc)
else
    NET=$(echo ${numeric_value})
fi
if [ "$(bc -l <<<"${NET}+`cat ${PREFIX}net_amount`")" != "" ]; then
   echo $(bc -l <<<"${NET}+`cat ${PREFIX}net_amount`") > ${PREFIX}net_amount
fi

## Log ##
MEM=$(bc -l <<<"`cat ${PREFIX}mem_amount`/`cat ${PREFIX}count`/1024")
CPU=$(bc -l <<<"`cat ${PREFIX}cpu_amount`/`cat ${PREFIX}count`")
NET=$(cat ${PREFIX}net_amount)
DISK_TPS=$(cat ${PREFIX}tps)
DISK_READ=$(cat ${PREFIX}io_read)
DISK_WRITE=$(cat ${PREFIX}io_write)

#Duration
SPENT=$(bc -l <<<"(`date +%s`-`cat ${PREFIX}time_init`)/60")

echo "     | $(printf '%.*f\n' 2 ${SPENT})     | $(printf '%.*f\n' 2 ${MEM}) | $(printf '%.*f\n' 2 ${CPU}) |  $(printf '%.*f\n' 2 ${NET}) | $(printf '%.*f\n' 2 ${DISK_TPS}) | $(printf '%.*f\n' 2 ${DISK_READ}) | $(printf '%.*f\n' 2 ${DISK_WRITE}) |" >> $1