#!/bin/bash

####
# IMPORTANT!!! DANGER!!!
# Deletes all IPs and Keys for ALL Instances
####


### make sure we user wants this!!
NON_INTERACTIVE=0
for arg in "$@"; do
  if [ $arg = '--non-interactive' ]; then
    NON_INTERACTIVE=1
  fi
done

### start

regions=$(aws ec2 describe-regions --region us-east-1 --output text | cut -f4)

for region in ${regions}; do
  echo "Region $region"

  if [ $NON_INTERACTIVE -eq 0 ]  ;then
    echo -n "*** Are you sure to delete all IPS and KEYS in region ${region} (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Nn]}" ] ;then
        exit 1
    fi
  fi

  ipinfos=$(aws ec2 describe-addresses --region "$region" --output text)

  keyinfos=$(aws ec2 describe-key-pairs --region "$region" --output text)

  echo -e "IP Info\n$ipinfos"
  echo -e "Key Info\n$keyinfos"

  IFS=$'\n'

  # delete all keys in region
  for keyinfo in ${keyinfos}; do
    keyId=$(echo $keyinfo | cut -f5)
    echo "Deleting key $keyId"
    echo $(aws ec2 delete-key-pair --region "$region" --key-pair-id "$keyId")
  done

  # delete all ips in region
  for ipinfo in $ipinfos; do
    echo "IP INFO: " $ipinfo
    ip=$(echo ${ipinfo/$'\n'} | cut -f5)
    allocid=$(echo $ipinfo | cut -f2)
    echo "IP:$ip ALLOCID:$allocid"
    echo "Releasing ip $ip"
    echo $(aws ec2 release-address --region "$region" --allocation-id "$allocid")
  done

done;