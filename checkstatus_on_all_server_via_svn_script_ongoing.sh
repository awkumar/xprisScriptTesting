


      #####################################################################################
      #                                                                                                               #
      #               Name of Script: checkstatus_on_all_server_via_svn_script_ongoing.sh                            #
      #####################################################################################

      ##Purpose       :     To check status 

      echo "*******************************To check status *****************************"
      
echo "Enter the server name on which you want to check status"

read server_name

ssh $server_name

echo " Enter the process to which we want to check status"

read SERVICE
#cntlmd, httpd


#SERVICE='httpd'
 

if ps ax | grep -v grep | grep $SERVICE > /dev/null

then

    echo "$SERVICE service running, everything is fine on $(hostname) as on $(date)" 
    echo "$SERVICE  Running!" | mail -s "$SERVICE UP " awinash.kumar@tieto.com
    #echo "Running  on $(hostname) as on $(date)"

else

    echo "$SERVICE is not running on $(hostname) as on $(date)"
    #echo "Not Running  on $(hostname) as on $(date)"
    echo "$SERVICE is not running!" | mail -s "$SERVICE down" awinash.kumar@tieto.com

fi

