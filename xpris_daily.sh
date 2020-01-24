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

#
# Run metasync from XBAS production DB
#
LOG="Importing latest db tables from PROD ..."
CMD="/opt/xpris/xpris1/script/db/run_meta_sync.sh all"
run "$LOG" "$CMD"

TARGET=$(ls -1tr /opt/xpris/xpris1/jenkins/jobs/1740_All_xpris/lastSuccessful/archive/Xpn/deploy/tcn* |tail -1) 
FILENAME=$(basename ${TARGET%.*}) 
echo "Latest build for project 1740: [${FILENAME}]"

#
#    Utv1
#
LOG="Projectspecific DB updates Utv11 1730..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_db_update_proj.sh utv11 1730"
run "$LOG" "$CMD"
    
#LOG="Compiling latest Tuxedo code on Utv11 ..."
#CMD="ssh -q xprisu@localhost . ~/.profile 11 > /dev/null 2>&1; ~/bin/build_tuxedo deploy 1711 utv1 > /dev/null && grep -e '.*000: ' /opt/xpristst/xpris1/log/tuxlog_utv1"
#run "$LOG" "$CMD"
    
LOG="Deploying latest WAR on Tomcat Utv11 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_build_cli deploy 1730 xp001utv1.ddc.teliasonera.net utv11"
run "$LOG" "$CMD"
    
LOG="Deploying latest EAR on Jboss Utv11 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/build_jboss_xp001xpristst deploy 1730 jbossutv1 xprisjboss"
run "$LOG" "$CMD"



#
# Utv2
#
LOG="Projectspecific DB updates Utv12 1740 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_db_update_proj.sh utv12 1740"
run "$LOG" "$CMD"

#LOG="Building and deploying latest Tuxedo on Utv12 ..."
#CMD="ansible-playbook  -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/utv2 /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/xpris_dev_tuxedo_tuxtcn.yml"
#run "$LOG" "$CMD"

LOG="Updating Tomcat war files"
CMD="ansible-playbook  -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/utv2 /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/xpris_deploy_webapps.yml"
run "$LOG" "$CMD"

LOG="Deploying latest EAR on Jboss Utv12 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/build_jboss_xp001xpristst deploy 1740 jbossutv2 xprisjboss"
run "$LOG" "$CMD"


#
# Utv3
#
    
#LOG="Projectspecific DB updates Utv 13 1721 ..."
#CMD="/opt/xpristst/xpris1/script/kaprifol_db_update_proj.sh utv13 1721"
#run "$LOG" "$CMD"
    
#LOG="Compiling latest Tuxedo code on Utv13 ..."
#CMD="ssh -q xprisu@localhost . ~/.profile 13 > /dev/null 2>&1; ~/bin/build_tuxedo deploy 1710 utv3 > /dev/null && grep -e '.*000: ' /opt/xpristst/xpris1/log/tuxlog_utv3"
#run "$LOG" "$CMD"
    
LOG="Deploying latest WAR on Tomcat Utv13 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_build_cli deploy 1721 xp001utv3.ddc.teliasonera.net utv13"
run "$LOG" "$CMD"
    
LOG="Deploying latest EAR on Jboss Utv13 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/build_jboss_xp001xpristst deploy 1721 jbossutv3 xprisjboss"
run "$LOG" "$CMD"


#
# Test1
#
    
LOG="Projectspecific DB updates Test11 1730 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_db_update_proj.sh  test11 1730"
run "$LOG" "$CMD"
    
#LOG="Compiling latest Tuxedo code on Test11 ..."
#CMD="ssh -q xprist@localhost . ~/.profile 11 > /dev/null 2>&1; ~/bin/build_tuxedo deploy 1711 test1 > /dev/null && grep -e '.*000: ' /opt/xpristst/xpris1/log/tuxlog_test1"
#run "$LOG" "$CMD"
    
LOG="Deploying latest WAR on Tomcat Test11 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_build_cli deploy 1730 xp001test1.ddc.teliasonera.net test11"
run "$LOG" "$CMD"
    
LOG="Deploying latest EAR on Jboss Test11 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/build_jboss_xp001xpristst deploy 1730 jbosstest1 xprisjboss"
run "$LOG" "$CMD"
    
#
# Test2
#

LOG="Projectspecific DB updates Test12 1740 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_db_update_proj.sh test12 1740"
run "$LOG" "$CMD"

#LOG="Deploying latest Tuxedo on Test12 ..."
#CMD="ansible-playbook  -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/test2 /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/xpris_deploy_tuxedo_tuxtcn.yml"
#run "$LOG" "$CMD"

LOG="Updating Tomcat war with latest war files"
CMD="ansible-playbook  -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/test2 /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/xpris_deploy_webapps.yml"
run "$LOG" "$CMD"

LOG="Deploying latest EAR on Jboss Test12 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/build_jboss_xp001xpristst deploy 1740 jbosstest2 xprisjboss"
run "$LOG" "$CMD"


#
# Test3
#
    
#LOG="Projectspecific DB updates Test13 1721 ..."
#CMD="ssh -q xprist@localhost ~/bin/db_update_proj.sh test13 1721"
#run "$LOG" "$CMD"
    
#LOG="Compiling latest Tuxedo code on Test13 ..."
#CMD="ssh -q xprist@localhost . ~/.profile 13 > /dev/null 2>&1; ~/bin/build_tuxedo deploy 1710 test3 > /dev/null && grep -e '.*000: ' /opt/xprists        t/xpris1/log/tuxlog_test3"
#run "$LOG" "$CMD"

LOG="Deploying latest WAR on Tomcat Test13 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/kaprifol_build_cli deploy 1721 xp001test3.ddc.teliasonera.net test13"
run "$LOG" "$CMD"
    
LOG="Deploying latest EAR on Jboss Test13 ..."
CMD="/opt/xpris/home/xprisadm/bin/xpris_daily_scripts/build_jboss_xp001xpristst deploy 1721 jbosstest3 xprisjboss"
run "$LOG" "$CMD"


LOG="Deploying changes for xpn portal on Controller machine...."
#extra_args1=( "env=utv12" "branch=17.4.0" "tcn_version=$(basename ${TARGET%.*})") 
#CMD="ansible-playbook -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/controller /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/tomcat_tomxpnportal.yml -e $extra_args1"
#run "$LOG" "$CMD"

CMD="/opt/xpris/home/xprisadm/bin/update_xpnportal.sh utv12 $FILENAME 17.4.0"
run "$LOG" "$CMD"

#extra_args2=( "env=test12" "branch=17.4.0" "tcn_version=$(basename ${TARGET%.*})") 
#CMD="ansible-playbook -i /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/controller /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/tomcat_tomxpnportal.yml -e $extra_args2"
#run "$LOG" "$CMD"

CMD="/opt/xpris/home/xprisadm/bin/update_xpnportal.sh test12 $FILENAME 17.4.0"
run "$LOG" "$CMD"

#
# Send emeta-file to Telsims 
#
LOG="Metadataexport to Telsims from test12 ..."
CMD="/opt/xpris/xpris1/script/runbatchTestSendemetadata.sh test2"
run "$LOG" "$CMD"

LOG="Metadataexport to Telsims from itest ..."
CMD="/opt/xpris/xpris1/script/runbatchTestSendemetadata.sh itest"
run "$LOG" "$CMD"

# Import metadata from XTAS
LOG="Metadataimport from XTAS to itest ..."
CMD="/opt/xpris/xpris1/script/runbatchxtas.sh itest"
run "$LOG" "$CMD"

finnish

####
#    MAIN end
####
