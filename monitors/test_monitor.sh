echo "     | Duration | Memory     | CPU   |  NETWORK  | Disk(tps) | Disk(reads) | Disk(writes) |" >> $1
echo "     |----------|------------|-------|-----------|-----------|-------------|--------------|" >> $1

date +%s > /tmp/temp_time_init

free | grep Mem | awk -F' ' '{print $2}' > /tmp/temp_mem_total
free | grep Mem | awk -F' ' '{print $3}' > /tmp/temp_mem_initial

echo $$ > /tmp/temp_monitor_pid
echo 0 > /tmp/temp_count
echo 0 > /tmp/temp_mem_amount
echo 0 > /tmp/temp_cpu_amount
echo 0 > /tmp/temp_net_amount
echo 0 > /tmp/temp_tps
echo 0 > /tmp/temp_io_read
echo 0 > /tmp/temp_io_write

while [ true ]; do
   $2/monitors/test_monitor_agent.sh $1
   sleep 1
done