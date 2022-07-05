#!/bin/bash
dattosite=https://zinfandel.centrastage.net/csm/profile/downloadMacAgent/[site id]
if grep -Fxq "127.0.0.1 $(uname -n)" "/etc/hosts"
then
    echo "host name found in hosts"
else
    echo "host name not found in hosts"
	echo "adding hostname to hosts..."
	printf "\n127.0.0.1 $(uname -n)" >> "/etc/hosts"
fi

 if test -d "/Applications/AEM Agent.app"
 then
	 echo "Datto RMM is installed"
 else
  echo "Datto RMM isn't installed running repair operation please wait"
  rm -rf /usr/local/share/Centrastage
  rm -rf /var/root/.mono/registry/CurrentUser/software/centrastage
  rm  -rf /var/tempdatto/*
  mkdir /var/tempdatto
  curl $dattosite -o /var/tempdatto/Datto.zip
  unzip /var/tempdatto/Datto.zip -d /var/tempdatto
  installer -pkg /var/tempdatto/AgentSetup/CAG.pkg -target / -verbose
  sleep 20
 fi


 if pgrep CentraStage; 
 then
     echo 'Datto RMM is installed and running : )';
 else
	 echo 'Datto RMMs service is not running writing detail to console and attempting to launch service'
   launchctl list com.centrastage.cag
  launchctl start com.centrastage.cag
   launchctl list com.centrastage.cag
 fi
