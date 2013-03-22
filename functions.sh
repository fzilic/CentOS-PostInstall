# this file declares common use functions 

checkLastReturn() {
  if [[ "$?" != "0" ]]; then 
    echo $?
    echo $1
    exit 0
  fi
}

printExecuteCommand() {
  if [ "$#" -ne "2" ]; then
    echo "Wrong function call."
    exit 0
  fi
  
  echo $2
  if [ "$1" = 'f' ]; then
    echo $2 | /bin/bash
  fi
}