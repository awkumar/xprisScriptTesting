#!/bin/bash  

# This script is a temporary script, used by old sehan server to update the tcn version and branch of the new portalsite. 
# When jenkings are migrated to svn controller machine hopfully jenkins can control this.

env=${1}
tcn_version=${2}
branch=${3}


echo "Environmentspecific updates for xpnportalen env is $env branch is $branch tcn version is $tcn_version"
cd  /opt/xpris/xpris1/jenkins/workspace/System/xpris/ansible-playbooks/ansible-playbook/;
ansible-playbook --become-user=xprisadm -i controller  tomcat_tomxpnportal.yml --tags "environments" --extra-vars "env=$env branch=$branch tcn_version=$tcn_version"
ansible-playbook --become-user=xprisadm -i controller  tomcat_tomxpnportal.yml  --tags "deploy_environments" 

