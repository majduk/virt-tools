#!/usr/bin/env bash

net_name=sandbox_oam
image_name=s_rally
instance_prefix=metadata-test
host=var0tf1a-cmp3s40d2yf-hr
availability_zone=INT

net_uuid=$(nova tenant-network-list | grep $net_name | head -n1 | awk '{ print $2 }')

if [ -z $net_uuid ];then
   echo "No such net: $net_name"
   exit 1
fi

image_uuid=$(nova image-list | grep $image_name | head -n1 | awk '{ print $2 }')
if [ -z $image_uuid ];then
   echo "No such image: $image_name"
   exit 1
fi

if [ ! -z $host ];then
   host_az=$( nova host-list | grep $host | head -n1 | awk '{print $6}' )
   if [ -z $host_az  ];then
     echo "No such host: $host"
     exit 1
   fi
   availability_zone=${host_az}:${host}
fi

for id in {1..5}; do
  openstack server create --image $image_uuid --flavor m1.tiny \
  --availability-zone $availability_zone \
  --nic net-id=$net_uuid ${instance_prefix}-${id}
done

echo "Waiting for instances build"
sleep 60
nova list | grep ${instance_prefix}

for id in {1..5}; do
  echo "-- ${instance_prefix}-${id} metadata access --"
  nova console-log ${instance_prefix}-${id} | grep -A1 "169.254.169.254"
done


for id in {1..5}; do
  echo "Deleting ${instance_prefix}-${id}"
  openstack server delete ${instance_prefix}-${id}
done
