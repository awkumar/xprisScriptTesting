
START/STOP/RESTART TUXEDO OR TOMCAT -----------------------------
ansible-playbook  --become-user=xprisadm  -i <inventory-file> xpris_execute.yml
Start/Stop Tuxedo
ansible-playbook  --become-user=xprisadm  -i <inventory-file> xpris_execute.yml --tags "start-tuxtcn"
ansible-playbook  --become-user=xprisadm  -i <inventory-file> xpris_execute.yml --tags "stop-tuxtcn"
Start/Stop/Restart Tomcat
ansible-playbook  --become-user=xprisadm  -i <inventory-file> xpris_execute.yml --tags "start-tomtcn"
ansible-playbook  --become-user=xprisadm  -i <inventory-file> xpris_execute.yml --tags "stop-tomtcn"
ansible-playbook  --become-user=xprisadm  -i <inventory-file> xpris_execute.yml --tags "restart-tomtcn"

-----------------------------------------------------------------

XPNPORTAL -------------------------------------------------------
TODO: (remove variables when xprisdaily is migrated to new server from sehan, use jenkins and svn instead to update template file and just run this task)

Command below is currently used on sehan in xpris_daily to update portal sites branch and tcn version.
ansible-playbook --become-user=xprisadm -i controller  tomcat_tomxpnportal.yml  --tags "environments" --extra-vars "env=utv13 branch=17.3.1 tcn_version=TCN8888"
To update other environment variables, then edit: roles/tomcatXpnPortal/templates/environments.xml.j2 make edit -> commit, then run task below:
ansible-playbook --become-user=xprisadm -i controller  tomcat_tomxpnportal.yml  --tags "environments"

-----------------------------------------------------------------

NEW INSTALLATIONS -----------------------------------------------
ansible-playbook  --become-user=xprisadm  -i <inventory-file> install.yml
Important: Some manual steps still exist that may be required to be setup after fresh installations, check /system/ansible/xpris/ansible-playbooks/ansible-playbook/templates/README.txt
ansible-playbook  --become-user=xprisadm  -i <inventory-file> install_applications.yml

Only for UTV hosts
To build and pack Tuxedo TCN or TXN run the playbooks below.
ansible-playbook  --become-user=xprisadm  -i <inventory-file> xpris_dev_tuxedo_tuxtcn.yml
ansible-playbook  --become-user=xprisadm  -i <inventory-file> xpris_dev_tuxedo_tuxtxn.yml

----------------------------------------------------------------

