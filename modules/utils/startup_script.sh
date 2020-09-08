#!/bin/bash -i
# We use -i to start the shell in interactive mode
start=$(date +%s)

# We run the startup script as root
echo "Running as user" $(whoami)

# Save the Generated Key to the server
echo "${git_ssh_key}" > ~/.ssh/git_ssh_key
chmod 600 ~/.ssh/git_ssh_key

# Generate Public part of the key
ssh-keygen -y -f ~/.ssh/git_ssh_key > ~/.ssh/git_ssh_key.pub
chmod 644 ~/.ssh/git_ssh_key.pub

# Copy and save the AWS credentials
# We need AWS to get the docker images from ECR
[ ! -d ~/.aws ] && mkdir -p ~/.aws
echo "${aws_creds}" > ~/.aws/credentials

# Save the variables into bashrc for later use
# Note that the below is added without bash-level substitution
if ! grep -q 'ssh-add' ~/.bashrc; then
cat << 'EOT' >> ~/.bashrc
alias taillog="tail -f /var/log/syslog | egrep 'cloud-init|startup-script'"
alias catlog="cat /var/log/syslog | egrep 'cloud-init|startup-script'"
eval $(ssh-agent -s)
ssh-add ~/.ssh/git_ssh_key
export APP=${app_prefix}
export APP_PASSWORD=${app_pass}
EOT
fi

# Source Saved variables
source ~/.bashrc
# Keyscan github to allow cloning of private repository
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
sudo apt update && sudo apt -y install make git zip unzip

# This is to clone the app repository which contains adtional code for setup
# TODO: install jvb from apt, more details here: https://github.com/hermanbanken/jitsi-terraform-scalable/blob/master/gcp/scripts/jitsi-jvb.sh.tpl

if [ ! -d ~/app_repo ]; then
    git clone app_repo_link
fi

# Make dep script installs docker, java and other needed dependencies
cd ~/app_repo
make dep << EOS
echo This is running as group \$(id -gn)
EOS

# change hostname to hostname.app.com
if [[ $(hostname) != *.app.com ]]; then
    sudo hostname $(hostname).app.com
fi

export HOSTNAME=$(hostname)
echo Setting up $HOSTNAME

if [ ! -f /root/route53.sh ] || ! grep -q $HOSTNAME /root/route53.sh ; then
    sudo cp config/dev/route53.sh /root/
    sudo sed -i 's/dev.app.com/'$HOSTNAME'/g' /root/route53.sh
    sudo chmod u+x /root/route53.sh
fi

sudo sh /root/route53.sh

make jvb
# this script is used to install the custom jvb images from our ecr
echo "JVB INSTALLED"

#  This script install telegraf and send stats to app_prefix.app.com
make telegraf
echo "Telegraf installed and up"


# Wait for telegraf to start and then restart it
sleep 5
systemctl daemon-reload
systemctl restart telegraf

# Log how long it took for the script to run
echo "ALL DONE!"
end=$(date +%s)

echo $((end-start))
echo $(uptime)
