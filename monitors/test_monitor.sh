date +%s > /tmp/temp_time_init

# Get Total Memory in BYTES
sysctl -n hw.memsize > /tmp/temp_mem_total
python3 -c "import psutil; print(psutil.virtual_memory().used)" > /tmp/temp_mem_initial

echo $$ > /tmp/temp_monitor_pid
echo 0 > /tmp/temp_count
echo 0 > /tmp/temp_mem_amount
echo 0 > /tmp/temp_test

while [ true ]; do
   $8/monitors/test_monitor_agent.sh $1 $2 $3 $4 $5 $6 $7
   sleep 5
done