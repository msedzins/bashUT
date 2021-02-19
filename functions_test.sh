#!/bin/bash
##This file contains unit tests for corresponding file

set -e
source functions.sh

function validate_status {
    if [[ $? != 0 ]]; then
        echo "Tests failed"
    else
        echo "Tests succeeded."
    fi

}
trap validate_status EXIT 

########
echo "Test get_resources - 3 items returned."
function terraform { 
    cat terraform_response_vm_list.txt
    }   
get_resources "efk"
[[ ${#RESPONSE[@]} == 3 ]]
echo "OK"

########
echo "Test declare_dynamic_var"
unset TF_VAR_test1
declare_dynamic_var test1 test_value
[[ $TF_VAR_test1 == "test_value" ]]
echo "OK"

########
echo "Test get_vm_private_ip"
function terraform { 
    cat terraform_response_vm_details.txt 
    }   
RESPONSE=$(get_vm_private_ip "module.masters.opc_compute_orchestrated_instance.ovm[1]")
[[ $RESPONSE == "10.202.108.179" ]]
echo "OK"

########
echo "Test format_list"
ip_list=( "ip1" "ip2" "ip3")
RESPONSE=$(format_list  "${ip_list[@]}")
[[ $RESPONSE == '["ip1","ip2","ip3"]' ]]
echo "OK"

########
echo "Test get_count"
ip_list="ip1 ip2 ip3"
RESPONSE=$(get_count  "$ip_list")
[[ $RESPONSE == 3 ]]
echo "OK"

########
echo "Test get_vm_number - 3 items returned."
function terraform { 
    cat terraform_response_vm_list.txt
    }   
function get_vm_private_ip { 
    echo "10.202.108.179"
    }   
RESPONSE=$(get_vm_number "masters" "10.202.108.179") 
echo $RESPONSE
[[ $RESPONSE == "0" ]]
echo "OK"

########
echo "Test get_vm_number - 1 item returned."
function terraform { 
    cat terraform_response_vm_list_1_item.txt
    }   
function get_vm_private_ip { 
    echo "10.202.108.179"
    }   
RESPONSE=$(get_vm_number "masters" "10.202.108.179") 
[[ $RESPONSE == "NONE" ]]
echo "OK"

########
echo "Test get_module"
RESPONSE=$(get_module "master")
[[ $RESPONSE == 'masters' ]]
echo "OK"
