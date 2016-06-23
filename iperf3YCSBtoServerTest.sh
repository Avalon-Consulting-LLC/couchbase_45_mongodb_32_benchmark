# ------------------
# - Script written by Darrel Cox (Avalon Consulting, LLC)
# -
# - This script is used to test iperf3 
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
   echo "     This script is used to test iperf3"
   echo ""
   echo "     NOTE: This script REQUIRES xmlsh, aws and json2xml already be install on the machine."
   echo ""
   echo "OPTIONS"
   echo ""
   echo "    -r (string) - REQUIRED - This is the AWS REGION where the servers are located"
   echo ""
   echo "    -s (string) - REQUIRED - This is the server(s) name prefix that's concatenated while looping to form the complete server name. (i.e. data1). This value should match the machine name used in the Vagrantfile."
   echo ""
   echo "    -n (number) - REQUIRED - This is servers that require the change"
   echo ""
   echo ""
   echo "SAMPLE"
   echo ""
   echo "    ./iperf3YCSBtoServerTest.sh -r us-west-2 -s server -n 9"
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

while getopts 'r:s:n:' OPTION
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

export XMLSH=~/xmlsh_1_3_1
export PATH=$PATH:$XMLSH/unix
# ------------------
# Main Processing
# ------------------
echo ""
logMsg "Run iperf3 Test against each Server" 

i=1
while [[ $i -le numOfServers ]]; do
   currServerName=${serverNamePrefix}${i}
   publicDnsName=`xmlsh -c "aws ec2 describe-instances --region ${awsRegion} | json2xml | xpath -s /*:object//*:member[@name='Value']/*:string[.='${currServerName}']/../../../../../*:member[@name='PublicDnsName']/*:string"`

   logMsg "Testing Server Number [" ${i} "] Server Name [" ${currServerName} "] publicDnsName [" ${publicDnsName} "]"
   iperf3 --client ${publicDnsName}

	(( i++ ))
done
