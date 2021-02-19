#!/bin/bash
set -e

function get_resources {
    local resource_type=$1  

    local resp=$(terraform state list  module.${resource_type}.opc_compute_orchestrated_instance.ovm)
    IFS=$'\n' read -d '' -r -a list <<< "$resp" && true

    #global variable is used so that we can pass list object
    RESPONSE=("${list[@]}") 
}

function get_count {
  local list="$@"
  local counter=0

  for ip in $list; do
      let counter+=1
  done
  echo  $counter
}

function get_vm_private_ip {
   local resource=$1

   #if one resource exits it should be address without []. It is handled automatically
   local resp=$(terraform state show  $resource)

   echo "$resp" | grep instance.0.ip_address | sed -E 's/.*= //'
}

function get_vm_shape {
   local resource_type=$1

   get_resources $resource_type
   for resource in ${RESPONSE[@]}; do
       local resp=$(terraform state show  $resource)
       echo "$resp" | grep instance.0.shape | sed -E 's/.*= //'
       return
    done
}

function declare_dynamic_var {
    eval TF_VAR_$1=$2
}

function get_vm_ip_list {
    local ip_list=() 
    local resource_type=$1

    get_resources $resource_type
    for resource in ${RESPONSE[@]}; do
      ip=$(get_vm_private_ip $resource)
      ip_list+=( $ip )
    done

    echo ${ip_list[@]}
}

function get_vm_number {
    local resource_type=$1
    local ip=$2

    get_resources $resource_type
   if [[ ${#RESPONSE[@]} == 1 ]]; then 
    echo "NONE"
    return
   fi

    for resource in ${RESPONSE[@]}; do
      local private_ip=$(get_vm_private_ip $resource)
      
      if [[ "$ip" == "$private_ip" ]]; then
        echo ${resource: -2:1}
        return
      fi
    done

    echo "NOT_FOUND"
} 

function format_list {
    local ip_list="$@"
    local response=[

    for ip in ${ip_list[@]}; do
      response+=\"$ip\",
    done
    response=${response::-1}]

    echo $response
} 

function get_module() {
  case "$1" in
        "master")
           echo "masters"
            ;;         
        "worker")
            echo "workers"
            ;;
        *)
          echo "Wrong usage"    
          exit 1
  esac
}

#if true means that script was not run with "source" command
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  echo Please "source" this file and use functions
fi
