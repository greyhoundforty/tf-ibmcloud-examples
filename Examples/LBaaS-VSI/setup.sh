#!/usr/bin/env bash

# Script Variables
DIALOG='\033[0;36m'
NC='\033[0m'

echo -n -e "${DIALOG}Please supply the datacenter you are deploying to? (ex: dal13, wdc07, etc${NC}  "
read -r DATACENTER

echo -n -e "${DIALOG}Please provide the Private VLAN where you will be deploying your virtual guests${NC}  "
read -r PRIVATE_VLAN

echo -n -e "${DIALOG}Please provide the Public VLAN where you will be deploying your virtual guests.${NC}  "
read -r PUBLIC_VLAN

echo -n -e "${DIALOG}Please provide the domain name for your virtual guests.${NC}  "
read -r DOMAIN

echo -n -e "${DIALOG}Please provide the private subnet for your Cloud Load Balancer.${NC}  "
read -r SUBNET
