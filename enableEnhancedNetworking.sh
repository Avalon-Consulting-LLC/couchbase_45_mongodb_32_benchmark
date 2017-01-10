#!/bin/ksh
# ------------------
# - Script written by Darrel Cox (Avalon Consulting, LLC)
# -
# - This script is used to Enable Enhanced Networking on all the database nodes
# -
# ------------------

# ------------------
# - Log a message
# ------------------
logMsg()
{
 echo `date +'%Y %b %d %T'` : $(basename $0) : ${*}
}

printUsage()
{
   echo ""
   echo ""
   echo "Usage: ./$(basename $0) -r awsRegion -s serverNamePrefix -n numOfServers"
   echo ""
   echo "DESCRIPTION"
   echo ""
   echo "     This script is used to Enable Enhanced Networking on all the database nodes."
   echo ""
   echo "     NOTE: This script REQUIRES xmlsh, aws and json2xml already be install on the machine."
   echo ""
   echo "OPTIONS"
   echo ""
   echo "    -r (string) - REQUIRED - This is the AWS REGION where the servers are located"
   echo ""
   echo "    -p (string) - REQUIRED - This is the server(s) name prefix that's concatenated while looping to form the complete server name. (i.e. data1). This value should match the machine name used in the Vagrantfile."
   echo ""
   echo "    -s (int) - REQUIRED - This is the server(s) number to start with. This value is appended to the -p prefix value to form the complete server name. (i.e. data1)"
   echo ""
   echo "    -n (int) - REQUIRED - This is servers that require the change"
   echo ""
   echo ""
   echo "SAMPLE - This will updated servers data1 - data9"
   echo ""
   echo "    ./enableEnhancedNetworking.sh -r us-west-2 -p data -s 1 -n 9 "
   echo ""
}

# ------------------
# Check the number of Option Parameters
# ------------------
if [ $# -lt 3 ]; then
   echo "Missing: Required Parameters"
   printUsage
   exit 1
fi

while getopts 'r:p:s:n:' OPTION
   do
      case ${OPTION} in
         r) rflag=1
            awsRegion=${OPTARG}
            ;;
         p) pflag=1
			serverNamePrefix=${OPTARG}
            ;;
         s) sflag=1
         startWith=${OPTARG}
            ;;
         n) nflag=1
         howManyServers=${OPTARG}
            ;;
         ?) printUsage
            exit 2
            ;;
      esac
done

if [ ! "${rflag}" ]; then
   logMsg "Missing: -r awsRegion"
   printUsage
   exit 2
fi

if [ ! "${pflag}" ]; then
   logMsg "Missing: -p serverNamePrefix"
   printUsage
   exit 2
fi

if [ ! "${sflag}" ]; then
   logMsg "Missing: -s Number of Servers starting value"
   printUsage
   exit 2
fi

if [ ! "${nflag}" ]; then
   logMsg "Missing: -n Total Number of Servers"
   printUsage
   exit 2
fi

# ------------------
# Main Processing
# ------------------

awsProfile=$AWS_DEFAULT_PROFILE
echo ""
logMsg "Using profile [" ${awsProfile} "]"
logMsg "Enabling Enhanced Networking for [" ${howManyServers} "] servers in the AWS Region [" ${awsRegion} "] for server names that begin with [" ${serverNamePrefix} "] that are in the stopped state." 

stateCode=80  # Valid state codes are 16 - running, 48 - terminated, 64 - stopping, 80 - stopped. 
i=${startWith}
numOfServers=$(( ${i} + ${howManyServers} - 1 ))

while [[ $i -le numOfServers ]]; do
    currServerName="${serverNamePrefix}$(printf '%02d' $i)"
	instanceID=`xmlsh -c "aws ec2 describe-instances --region ${awsRegion} --profile ${awsProfile} | json2xml | xpath -s /*:object//*:member[@name='Value']/*:string[.='${currServerName}']/../../../../../*:member[@name='State']/*:object/*:member[@name='Code']/*:number[.='${stateCode}']/../../../../*:member[@name='InstanceId']/*:string"`

   `aws --debug --region ${awsRegion} ec2 modify-instance-attribute --instance-id ${instanceID} --sriov-net-support simple > modify-instance-attribute.log 2>&1`

	if [ $? -eq 0 ]; then
	   logMsg "Server Number [" ${i} "] Modification Complete for Server Name [" ${currServerName} "] Instance ID [" ${instanceID} "] - Return Code [" $? "]"
	else
	   logMsg "Server Number [" ${i} "] Modification FAILED for Server Name [" ${currServerName} "] Instance ID [" ${instanceID} "] - Return Code [" $? "]"
	fi
	logMsg `cat modify-instance-attribute.log | grep "awscli.errorhandler - DEBUG"`

	(( i++ ))
done
