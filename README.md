# Purpose

Example of lightweight approach to writing unit tests for bash scripts.

Consists of:
1. `functions.sh` - set of bash fuctions
2. `functions_test.sh` - set of unit tests

# Key points

1. Stubbing calls to external functions

```bash
function terraform { 
    cat terraform_response_vm_list.txt
    }  
```

**Note:** Sometimes might be also useful to export function definitions to sub-shell with:
```bash
export -f function_name
```

2. Stopping tests with proper message when any of the assertions is not met

```bash
set -e

function validate_status {
    if [[ $? != 0 ]]; then
        echo "Tests failed"
    else
        echo "Tests succeeded."
    fi

}
trap validate_status EXIT 
```

3. Finding out whether the script was sourced or called directly

```bash
#if true means that script was not run with "source" command
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  echo "Some action"  
fi
```
