#!/bin/ksh
# ------------------
# - Script written by Darrel Cox (Avalon Consulting, LLC)
# -
# - This script is used to reconfigure the Couchbase cluster after the AWS servers have been restarted
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
   echo "     This script is used to reconfigure the Couchbase cluster after the AWS servers have been restarted"
   echo ""
   echo "OPTIONS"
   echo ""
   echo "    -r (string) - REQUIRED - This is the AWS REGION where the servers are located"
   echo ""
   echo "    -s (string) - REQUIRED - This is the server(s) name prefix that's concatenated while looping to form the complete server name. (i.e. data1). This value should match the machine name used in the Vagrantfile."
   echo ""
   echo "    -n (number) - REQUIRED - This is servers that require the change"
   echo ""
   echo "    -u (string) - REQUIRED - This is Couchbase admin User. It's expects the server being added use the same value"
   echo ""
   echo "    -s (string) - REQUIRED - This is Couchbase admin Password. It's expects the server being added use the same value"
   echo ""
   echo ""
   echo "SAMPLE"
   echo ""
   echo "    ./reconfigureCouchbaseClusterAfterAwsServersRestart.sh -r us-west-2 -s data -n 9 -u couchbase -p couchbase"
   echo ""
}

# ------------------
# Check the number of Option Parameters
# ------------------
if [ $# -lt 5 ]; then
   echo "Missing: Required Parameters"
   printUsage
   exit 1
fi

while getopts 'r:s:n:u:p:' OPTION
   do
      case ${OPTION} in
         r) rflag=1
            awsRegion=${OPTARG}
            ;;
         s) sflag=1
            serverNamePrefix=${OPTARG}
            ;;
         n) nflag=1
            numOfServers=${OPTARG}
            ;;
         u) uflag=1
            username=${OPTARG}
            ;;
         p) pflag=1
            password=${OPTARG}
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

if [ ! "${sflag}" ]; then
   logMsg "Missing: -s serverNamePrefix"
   printUsage
   exit 2
fi

if [ ! "${nflag}" ]; then
   logMsg "Missing: -n numOfServers"
   printUsage
   exit 2
fi

if [ ! "${uflag}" ]; then
   logMsg "Missing: -u username"
   printUsage
   exit 2
fi

if [ ! "${pflag}" ]; then
   logMsg "Missing: -p password"
   printUsage
   exit 2
fi

# ------------------
# Main Processing
# ------------------
echo ""
logMsg "Reconfiguring the Couchbase Cluster after the servers restart" 

i=1
while [[ $i -le numOfServers ]]; do
	currServerName=${serverNamePrefix}${i}
   publicIpAddress=`xmlsh -c "aws ec2 describe-instances --region ${awsRegion} | json2xml | xpath -s /*:object//*:member[@name='Value']/*:string[.='${currServerName}']/../../../../../*:member[@name='PublicIpAddress']/*:string"`

   # Server Number 1 is the Main Cluster Server
   if [ $i -eq 1 ]; then
      clusterPublicIpAddress=${publicIpAddress}
   fi

   # Server Number > 1 are added the cluster domain
   if [ $i -gt 1 ]; then
      vagrantResponse=`vagrant ssh ${serverNamePrefix}1 -c "/opt/couchbase/bin/couchbase-cli server-add -c ${clusterPublicIpAddress}:8091 -u ${username} -p ${password} --server-add=${publicIpAddress}:8091 --server-add-username=${username} --server-add-password=${password} --services=data,index,query 2>&1"`

      if [ $? -eq 0 ]; then
         logMsg "Server Number [" ${i} "] server-add Complete for Server Name [" ${currServerName} "] Public IP Address [" ${publicIpAddress} "] - Return Code [" $? "]"
      else
         logMsg "Server Number [" ${i} "] server-add FAILED for Server Name [" ${currServerName} "] Public IP Address [" ${publicIpAddress} "] - Return Code [" $? "]"
      fi
      logMsg ${vagrantResponse}
   fi
	(( i++ ))

done
