#!/bin/bash


for users in $(dscl . list /Users | grep -v "^_"|grep -v macports |grep -v nobody|grep -v root| grep -v AddigySSH |grep -v daemon); do
     
   LockoutInfo+="$users $(/usr/bin/dscl . -readpl /Users/"$users" accountPolicyData failedLoginCount) |"
done
echo $LockoutInfo

UDFOut=$LockoutInfo


ExitCode=0 # This would be set to 0 or 1 somewhere in your script.

XMLPath=$(find /var/root/.mono/registry -name "values.xml") # Get the correct path of the values.xml file.

XMLTemp=$(cat $XMLPath | grep -v "</values>") # Create a string variable of the content of the values.xml file barring the last line.

XMLTemp="$XMLTemp"$'\n'"<value name=\"Custom6\" type=\"string\">$UDFOut</value>"$'\n'"</values>" # Append the UDFOut variable to the string variable containing the contents of values.xml. You must replace X with a number 1-10 for the respective UDF.

rm $XMLPath # Delete original values.xml

echo $XMLTemp >> $XMLPath # Copy the contents of the original values.xml plus append into a new values.xml

exit $ExitCode # Exit with respective ExitCode.
