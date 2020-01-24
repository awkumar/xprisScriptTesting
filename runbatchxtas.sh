#!/bin/bash

# functions
return_code()
{
  RETURN_VALUE=$?
  if [ $RETURN_VALUE -ne 0 ]; then 
    echo "Failed with $RETURN_VALUE in $ENV"
    exit $RETURN_VALUE
  fi
} 

usage()
{
        echo
        echo " Usage `basename $0` ENVIRONMENT"
        echo "   Example `basename $0` test13"
        echo
        exit 0
}

# end functions

# Check for arguments

if [ $# -lt 1  ]; then
  usage
fi

ARG1=$1

case "$ARG1" in
  "test1" | "test11" )
      export ENV=test1
      export PORT=25500
      export FOLDER=sys03
      ;;
  "test2" | "test12" )
      export ENV=test2
      export PORT=25600
      export FOLDER=sys03
      ;;
  "test3" | "test13" )
      export ENV=test3
      export PORT=25700
      export FOLDER=sys03
      ;;
  "itest" )
      export ENV=itest
      export PORT=35500
      export FOLDER=acc
      ;;
esac
printf "\n Copying information to new server xp001xpristst.gad.teliasonera.net"
scp -q -p /opt/xpristst/xpris1/domains/FTP/Clearinghouse/Xtas/* xpris@xp001xpristst.gad.teliasonera.net:/opt/xpristst/xpris1/domains/FTP/Clearinghouse/Xtas
printf "\n----------"
printf "\n-- Triggering batchjobb for :"
printf "\n-- ${ENV} - ${PORT} "
printf "\n----------\n"
/usr/bin/curl -s http://xp001xpristst.gad.teliasonera.net:${PORT}/xpnproxy/batch/runbatch.jsp?batchName=xtasagreement&action=start
return_code
printf "\n\n----------"
printf "\n-- Batch has started"
printf "\n----------\n\n"

printf "\n----------"
printf "\n-- Metadataexport done. "
printf "\n----------\n"
