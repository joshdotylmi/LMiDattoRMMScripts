#!/bin/zsh

# Extension attribute to report all user accounts who have a secure token
# If a user is found to have a secure token, the results will be displayed as:
#   Admins: user1, user2 (or "None" if none found)
#   Non-Admins: user1, user2 (or "None" if none found)
#
# If no user is found to have a secure token, the result will be:
#   "No Secure Token Users"
# If an unsupported file system is found, the result will be:
#   Unsupported File System: (File System Type)
#https://github.com/bp88/Jamf-Pro-Extension-Attributes
# Variable to determine File System Personality
fsType="$(/usr/sbin/diskutil info / | /usr/bin/awk 'sub(/File System Personality: /,""){print $0}')"
secureTokenAdmins=()
secureTokenUsers=()

# Loop through UUIDs of secure token holders
for uuid in ${$(/usr/sbin/diskutil apfs listUsers / | /usr/bin/awk '/\+\-\-/ {print $2}')}; do
    username="$(/usr/bin/dscl . -search /Users GeneratedUID ${uuid} | /usr/bin/awk 'NR==1{print $1}')"
    
    if /usr/sbin/dseditgroup -o checkmember -m "$username" admin &>/dev/null; then
        secureTokenAdmins+=($username)
    else
        secureTokenUsers+=($username)
    fi
done

if [[ -z ${secureTokenAdmins[@]} ]]; then
    stList="$(echo "Secure Token Users: None")"
else
    stList="$(echo "Secure Token Users: ${secureTokenAdmins[1]}")"
    
    for user in ${secureTokenAdmins[@]:1}; do
        stList+=", $user"
    done
fi

if [[ -z ${secureTokenAdmins[@]} ]] && [[ -z ${secureTokenUsers[@]} ]]; then
elif [[ -z ${secureTokenUsers[@]} ]]; then
else
    stList+="\n$(echo "Non-Admins with Secure Token: ${secureTokenUsers[1]}")"
    
    for user in ${secureTokenUsers[@]:1}; do
        stList+=", $user"
    done
fi

#!/bin/zsh

# Extension attribute to report all Volume Owners on Apple Silicon Macs
# If a user is found to be a volume owner, the results will be displayed as:
#   Admins: user1, user2 (or "None" if none found)
#   Non-Admins: user1, user2 (or "None" if none found)
#
# If no user is found to have be a volume owner, the result will be:
#   "No Volume Owners"
# If an unsupported file system is found, the result will be:
#   Unsupported File System: (File System Type)
# If an unsupported architecture, the result will be:
#   Unsupported Platform: (architecture)

# Variable to determine File System Personality
fsType="$(/usr/sbin/diskutil info / | /usr/bin/awk 'sub(/File System Personality: /,""){print $0}')"

# Variable to determine architecture of Mac
#platform=$(/usr/bin/arch)

# Exit if not running on Apple Silicon
#if [[ "$platform" = "arm64" ]]; then

# Variable to gather list of admins
# adminusers=$(/usr/bin/dscl . -read /Groups/admin | /usr/bin/awk '/GroupMembership:/{for(i=3;i<=NF;++i)print $i}')

# Creating empty arrays to store admin and non-admin volume owners
volumeOwnerAdmins=()
volumeOwnerUsers=()

# Determine number of APFS users
totalAPFSUsers=$(/usr/sbin/diskutil apfs listUsers / | /usr/bin/awk '/\+\-\-/ {print $2}' | /usr/bin/wc -l)

# Get APFS User information in plist format
apfsUsersPlist=$(/usr/sbin/diskutil apfs listUsers / -plist)

# Loop through all APFS Crypto Users
for (( n=0; n<$totalAPFSUsers; n++ )); do
    # Determine APFS Crypto User UUID
    apfsCryptoUserUUID=$(/usr/libexec/PlistBuddy -c "print :Users:"$n":APFSCryptoUserUUID" /dev/stdin <<<"$apfsUsersPlist")
    
    # Determine volume owner status for APFS Crypto User
    userVolumeOwnerStatus=$(/usr/libexec/PlistBuddy -c "print :Users:"$n":VolumeOwner" /dev/stdin <<<"$apfsUsersPlist")
    
    # If volume owner, determine username, otherwise move to next APFS user
    if [[ "$userVolumeOwnerStatus" = true ]]; then
        username="$(/usr/bin/dscl . -search /Users GeneratedUID ${apfsCryptoUserUUID} | /usr/bin/awk 'NR==1{print $1}')"
    else
        continue
    fi
    
    # For user in local directory, determine if volume owner is an admin
    if [[ -z "$username" ]]; then
        continue
    elif /usr/sbin/dseditgroup -o checkmember -m "$username" admin &>/dev/null; then
        volumeOwnerAdmins+=($username)
    else
        volumeOwnerUsers+=($username)
    fi
done

# Populate list of admin volume owners
if [[ -z ${volumeOwnerAdmins[@]} ]]; then
    voList="$(echo "Volume Owners: None")"
else
    voList="$(echo "Volume Owners: ${volumeOwnerAdmins[1]}")"
    
    for user in ${volumeOwnerAdmins[@]:1}; do
        voList+=", $user"
    done
fi

# Populate list of non-admin volume owners
if [[ -z ${volumeOwnerAdmins[@]} ]] && [[ -z ${volumeOwnerUsers[@]} ]]; then
    voList="$(echo "No Volume Owner")"
elif [[ -z ${volumeOwnerUsers[@]} ]]; then
else
    voList+="\n$(echo "Non-Admins with Volume Owners: ${volumeOwnerUsers[1]}")"
    
    for user in ${volumeOwnerUsers[@]:1}; do
        voList+=", $user"
    done
fi
#fi


#echo $voList
echo "$voList \n$stList"

UDFOut="$voList | $stList"

ExitCode=0 # This would be set to 0 or 1 somewhere in your script.

XMLPath=$(find /var/root/.mono/registry -name "values.xml") # Get the correct path of the values.xml file.

XMLTemp=$(cat $XMLPath | grep -v "</values>") # Create a string variable of the content of the values.xml file barring the last line.

XMLTemp="$XMLTemp"$'\n'"<value name=\"Custom27\" type=\"string\">$UDFOut</value>"$'\n'"</values>" # Append the UDFOut variable to the string variable containing the contents of values.xml. You must replace X with a number 1-10 for the respective UDF.

rm $XMLPath # Delete original values.xml

echo $XMLTemp >> $XMLPath # Copy the contents of the original values.xml plus append into a new values.xml

exit $ExitCode # Exit with respective ExitCode.
