#!/bin/bash
#---------------------------------------------------------------------------------------------
# This file is executed each morning to load production db copy of some tables and then apply
# project specific db scripts to environments.
# After that the different servers are deployed with the latest from the buildserver.
#
# Questions? 
#---------------------------------------------------------------------------------------------

# This means that we print to logfile...
DEBUG=true

####
#    functions begin
####
return_code()
{
  RETURN_VALUE=$?
  if [ $RETURN_VALUE -ne 0 ]; then
    printf "\n"
    logit "${1}\t-FAILED- with $RETURN_VALUE"
    #finnish
    #exit $RETURN_VALUE
  fi
}


init()
{
  DATE=$(date "+%Y%m%d")
  # create logfile, rotate if exist create date entry.
  LOG_FILE=/opt/xpris/xpris1/log/$(basename $0)_log_$DATE
  LOG_FILE_OUT=/opt/xpris/xpris1/log/$(basename $0)_log_$DATE_OUT
  touch $LOG_FILE_OUT
  if [ -f $LOG_FILE ]; then
    cp ${LOG_FILE} ${LOG_FILE}_${DATE}
    rm ${LOG_FILE}
  fi
  logit "$DATE - $(basename ${0}) started."
}

logit()
{
  if [ "$1" = "OK" ]; then
    printf "\t\t- ${1}\n" 
    printf "$(date "+%H:%M:%S.%N"): ${1}\n" >> $LOG_FILE
  elif [ "$1" = "BEGIN" ]; then
    printf "=========================================> \n" >> $LOG_FILE
    #printf " >> $(date "+%H:%M:%S.%N"): ${1}\n" >> $LOG_FILE
  elif [ "$1" = "END" ]; then
    #printf " << $(date "+%H:%M:%S.%N"): ${1}\n" >> $LOG_FILE
    printf "<========================================= \n" >> $LOG_FILE
  else
  #if [ $DEBUG = true ]; then
    printf "==> ${1}\n"
    printf "$(date "+%H:%M:%S.%N"): ${1}\n" >> $LOG_FILE
  #else
  #  printf "$(date "+%H:%M:%S.%N"): ${1}\n" >> $LOG_FILE
  fi
}

logc()
{ 
  export LASTLOG=$1
  #if [ $DEBUG = true ]; then
    #printf "$(date "+%H:%M:%S.%N"): ${1}"
    printf "==> ${1}"
    printf "$(date "+%H:%M:%S.%N"): ${1}\n" >> $LOG_FILE
  #else
  #  printf "$(date "+%H:%M:%S.%N"): ${1}" >> $LOG_FILE
  #fi
}

run()
{
  logc "${1}" 
  RUN=$($2)
  return_code "$1"
  logit "OK"
  if [ $DEBUG = true ]; then
    #printing to logfile only currently
    logit "BEGIN" 
    printf "\n$RUN \n\n" >> $LOG_FILE
    printf " \n\n" >> $LOG_FILE
    logit "END" 
  fi
}

finnish()
{
  logit "$(basename $0) Done."
  logit "Logfile: $LOG_FILE"
}

####
#    functions end
####

####
#    MAIN begin
####

init

TARGET=$(ls -1tr /opt/xpris/xpris1/jenkins/jobs/1740_All_xpris/lastSuccessful/archive/Xpn/deploy/tcn* |tail -1)
FILENAME=$(basename ${TARGET%.*})
echo "Deploying latest client for project 1740 [${FILENAME}]"

#
#Test2
#
#LOG="Projectspecific DB updates Test12 1740 ..."
#CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_db_update_proj.sh test12 1740"
#run "$LOG" "$CMD"

#LOG="Deploying latest Tuxedo on Test12 ..."
#CMD="ansible-playbook  -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/test2 /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/xpris_deploy_tuxedo_tuxtcn.yml"
#run "$LOG" "$CMD"

#LOG="Updating Tomcat war with latest war files"
#CMD="ansible-playbook  -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/test2 /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/xpris_deploy_webapps.yml"
#run "$LOG" "$CMD"

#LOG="Deploying latest EAR on Jboss Test12 ..."
#CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/build_jboss_xp001xpristst deploy 1740 jbosstest2 xprisjboss"
#run "$LOG" "$CMD"

LOG="Updating XPN Portal"
extra_args1="( env=utv12 branch=17.4.0 tcn_version=$FILENAME)"
#echo Value of extra_args1  $extra_args1

CMD="/opt/xpris/home/xprisadm/bin/update_xpnportal.sh utv12 $FILENAME 17.4.0" 
run "$LOG" "$CMD"

extra_args2=( "env=test12" "branch=17.4.0" "tcn_version=$(basename ${TARGET%.*})")
#CMD="ansible-playbook -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/controller /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/tomcat_tomxpnportal.yml  -e $extra_args2"
#run "$LOG" "$CMD"

CMD="/opt/xpris/home/xprisadm/bin/update_xpnportal.sh test12 $FILENAME 17.4.0"
run "$LOG" "$CMD"

finnish 

####
#    MAIN end
####
