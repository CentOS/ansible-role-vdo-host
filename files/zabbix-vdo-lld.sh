#!/bin/bash

# This script will query LVM and retrieve the VDO pool names
# for each pool it will then create a Zabbix Low Level Discovery item 
# Called by: cron
# Managed by: Ansible (don't edit)

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

# some variables
lld_file="/etc/zabbix/vdo-lld"

# Retrieve dynamically available duffy pools from DB
pool_names=$(lvs --noheadings --unbuffered -o pool_lv |grep -v "^\s*$" | tr -d ' ')

# Initialize lld file 
echo -en '- vdo.lld.pools { "data": [' > ${lld_file}

# Parsing $pool_names and adding to json
for pool in ${pool_names};do
  printf " {\"{#VDO_POOL_NAME}\": \"${pool}\"}," >> ${lld_file}
done
# Removing last comma for json
sed -i '$ s/,$//' ${lld_file}
# Closing file
printf ' ] }\n'>> ${lld_file}

# Reporting pools to Zabbix
zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -i ${lld_file} >/dev/null
