#!/bin/bash
set -e
export NODE_OPTIONS="--max-old-space-size=3000"


if [ -z "$VIRTUAL_ENV" ]; then
  echo "This requires the dogechia python virtual environment."
  echo "Execute '. ./activate' before running."
	exit 1
fi

if [ "$(id -u)" = 0 ]; then
  echo "The DogeChia Blockchain GUI can not be installed or run by the root user."
	exit 1
fi

# Allows overriding the branch or commit to build in dogechia-blockchain-gui
SUBMODULE_BRANCH=$1

UBUNTU=false
# Manage npm and other install requirements on an OS specific basis
if [ "$(uname)" = "Linux" ]; then
	#LINUX=1
	if type apt-get; then
		# Debian/Ubuntu
		UBUNTU=true
		sudo apt-get install -y npm nodejs libxss1
	elif type yum &&  [ ! -f "/etc/redhat-release" ] && [ ! -f "/etc/centos-release" ] && [ ! -f /etc/rocky-release ]; then
		# AMZN 2
		echo "Installing on Amazon Linux 2."
		curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -
		sudo yum install -y nodejs
	elif type yum && [ ! -f /etc/rocky-release ] && [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
		# CentOS or Redhat
		echo "Installing on CentOS/Redhat."
		curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -
		sudo yum install -y nodejs
	elif type yum && [ -f /etc/rocky-release ]; then
                # RockyLinux
                echo "Installing on RockyLinux"
                dnf module enable nodejs:12
                sudo dnf install -y nodejs
        fi

elif [ "$(uname)" = "Darwin" ] && type brew && ! npm version >/dev/null 2>&1; then
	# Install npm if not installed
	brew install npm
elif [ "$(uname)" = "OpenBSD" ]; then
	pkg_add node
elif [ "$(uname)" = "FreeBSD" ]; then
	pkg install node
fi

# Ubuntu before 20.04LTS has an ancient node.js
echo ""
UBUNTU_PRE_2004=false
if $UBUNTU; then
	UBUNTU_PRE_2004=$(python -c 'import subprocess; process = subprocess.run(["lsb_release", "-rs"], stdout=subprocess.PIPE); print(float(process.stdout) < float(20.04))')
fi

if [ "$UBUNTU_PRE_2004" = "True" ]; then
	echo "Installing on Ubuntu older than 20.04 LTS: Ugrading node.js to stable."
	UBUNTU_PRE_2004=true # Unfortunately Python returns True when shell expects true
	sudo npm install -g n
	sudo n stable
	export PATH="$PATH"
fi

if [ "$UBUNTU" = "true" ] && [ "$UBUNTU_PRE_2004" = "False" ]; then
	echo "Installing on Ubuntu 20.04 LTS or newer: Using installed node.js version."
fi

# For Mac and Windows, we will set up node.js on GitHub Actions and Azure
# Pipelines directly, so skip unless you are completing a source/developer install.
# Ubuntu special cases above.
if [ ! "$CI" ]; then
	echo "Running git submodule update --init --recursive."
	echo ""
	git submodule update --init --recursive
	echo "Running git submodule update."
	echo ""
	git submodule update
	cd dogechia-blockchain-gui

	if [ "$SUBMODULE_BRANCH" ];
	then
    git fetch
		git checkout "$SUBMODULE_BRANCH"
    git pull
		echo ""
		echo "Building the GUI with branch $SUBMODULE_BRANCH"
		echo ""
	fi

	npm install --legacy-peer-deps
	npm audit fix || true
	npm run build
else
	echo "Skipping node.js in install.sh on MacOS ci."
fi

echo ""
echo "DogeChia blockchain install-gui.sh completed."
echo ""
echo "Type 'cd dogechia-blockchain-gui' and then 'npm run electron &' to start the GUI."
