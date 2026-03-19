#!/usr/bin/env python3
# Author: Justin Sanderson 
# Purpose: This script is designed to extract a list of hosts from satellite based on their "satellite organization" and refreshing an Ansible Automation Platform (AWX) inventory.
#Example execution:  ./script.py  [ansible_inventory_name_src_server] [ansible_inventory_name_dest_server]

import requests
import json
import sys
from datetime import date
from datetime import datetime

# Set to True if you want to see all of the REST API Call EndPoints
debug_api = False

################# BEGIN FUNCTIONS #######################
def timestamp():
    now = datetime.now()
    dt_string = now.strftime("%d/%m/%Y-%H:%M:%S")
    return dt_string

# Function to find Inventory ID Number based on name string in Ansible
def get_INVID(name):
    api_query = 'https://awxserver.fqdn/api/v2/inventories/' + name + '&page_size=50'
    print(api_query)
    ansible_response = requests.get(api_query, auth=('username','password'), verify=False)
    for inventory in ansible_response.json()['results']:
        print(inventory)
        if name in inventory['name']:
            print("matched")
            invID = inventory['id']
            return invID

def add_host_to_inventory(hostname, INVID, debug_api):
    print("Adding Host " + hostname )
    add_host_api_url = "https://awxserver.fqdn/api/v2/inventories/" + str(DESTINVID) + "/hosts/"
    if debug_api is True:
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print("REST API EndPoint to AWX for adding hosts in " + src_inventory_arg + " = " + add_host_api_url)
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
    host_json = {"name" : hostname }
    add_host = requests.post(add_host_api_url , json = host_json ,auth=('username','password'), verify=False )
    #print(add_host.text)
    #print(add_host.status_code)

################# END FUNCTIONS #######################


# Convert ARG1 inventory name into an inventory id
src_inventory_arg = sys.argv[1]
SRCINVID = get_INVID(src_inventory_arg)

# Convert ARG1 inventory name into an inventory id
dest_inventory_arg = sys.argv[2]
DESTINVID = get_INVID(dest_inventory_arg)

src_ansible_response = requests.get('https://awxserver.fqdn/api/v2/inventories/300/hosts/?per_page=2000', auth=('username','password'), verify=False)

count = 0
dest_aap_inv = sys.argv[2]


# convert api response to json and loop over it at same time
print(timestamp() + " --> Begin Adding Hosts to " + dest_inventory_arg)
for host in src_ansible_response.json()['results']:
    if host['name'] is not None:
        add_host_to_inventory(host['name'] , SRCINVID, debug_api)
        count = count + 1
