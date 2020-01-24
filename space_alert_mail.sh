
# sript to see if the percentage of space is >= 90% 

echo "***********sript to see if the percentage of space is MORE ***********"
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  
  echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 15 ];
       

     
     then
    
        echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" |
       
             mail -s "Alert: Almost out of disk space $usep%" root@localhost.localdomain
                     echo " !!!! --->mail send to root@localhost.localdomain -----< "        

              #   if [ $? -eq 0 ]

               #       then
	        #           echo " mail send to root@localhost.localdomain \ "

        
  fi
done