# ------------------
# - Script written by Darrel Cox (Avalon Consulting, LLC)
# -
# - This script is used for installing iPerf3 testing required software 
# -
# ------------------

# ------------------
# - Log a message
# ------------------
logMsg()
{
 echo `date +'%Y %b %d %T'` : $(basename $0) : ${*}
}


# ------------------
# Main Processing
# ------------------
echo ""
logMsg "Installing iPerf3 testing required software" 

yum -y install zip
yum -y install unzip
yum -y install dos2unix

wget --quiet http://xmlsh-org-downloads.s3-website-us-east-1.amazonaws.com/archives/release-1_3_1/xmlsh_1_3_1.zip
unzip xmlsh_1_3_1.zip
export XMLSH=/home/centos/xmlsh_1_3_1
dos2unix $XMLSH/unix/xmlsh 
chmod a+x $XMLSH/unix/xmlsh
export PATH=$PATH:/usr/local/bin:$XMLSH/unix

curl -s "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip -q awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

chown -R centos:centos .
echo "export XMLSH=/home/centos/xmlsh_1_3_1/xmlsh_1_3_1" >> .bash_profile
echo "export PATH=$PATH:/usr/local/bin:$XMLSH/unix" >> .bash_profile

source .bash_profile