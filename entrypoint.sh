#! /bin/sh
set -e
trap exit INT
trap exit TERM

echo "Setting up codehost"
cd /config
touch "Note: all files are probably hidden"

echo "Importing authorized SSH keys from Github"
if [ ! -z ${GITHUB_USER} ]; then
	mkdir -p .ssh
	wget https://github.com/${GITHUB_USER}.keys --output-document=.ssh/authorized_keys
else
	echo -e "\033[0;31mYou have not set the GITHUB_USER variable –" \
		 "save your public ssh key to your Github account" \
		 "and set the variable to your username. \033[0m" 1>&2
	exit 1
fi

echo "Checking host keys"
if [ ! -f ".ssh/ssh_host_rsa_key" ]; then
	ssh-keygen -f .ssh/ssh_host_rsa_key -N '' -t rsa > /dev/null
fi
if [ ! -f ".ssh/ssh_host_ecdsa_key" ]; then
	ssh-keygen -f .ssh/ssh_host_ecdsa_key -N '' -t ecdsa > /dev/null
fi
if [ ! -f ".ssh/ssh_host_ed25519_key" ]; then
	ssh-keygen -f .ssh/ssh_host_ed25519_key -N '' -t ed25519 > /dev/null
fi

echo "Starting Docker-in-Docker service in the background"
dockerd-entrypoint.sh > /dev/null 2>&1 & 

echo "Running SSH service"
echo "You will only be able to connect if you have the private side of" \
	  "the key linked to your Github account"
exec /usr/sbin/sshd -D -f /etc/ssh/sshd_config
