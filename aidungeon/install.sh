#!/usr/bin/env bash
set -e
cd "$(dirname "${0}")"
BASE_DIR="$(pwd)"
PACKAGES=(aria2 git unzip wget)
# Tensorflow states 3.4.0 as the minimum version.
# This is also the minimum version with venv support.
# 3.8.0 and up only includes tensorflow 2.0 and not 1.15
MIN_PYTHON_VERS="3.4.0"
MAX_PYTHON_VERS="3.7.9"

version_check () {
	MAX_VERS=$(echo -e "$(python3 --version | cut -d' ' -f2)\n$MAX_PYTHON_VERS\n$MIN_PYTHON_VERS"\
	| sort -V | tail -n1)
	MIN_VERS=$(echo -e "$(python3 --version | cut -d' ' -f2)\n$MAX_PYTHON_VERS\n$MIN_PYTHON_VERS"\
	| sort -V | head -n1)
	if [ "$MIN_VERS" != "$MIN_PYTHON_VERS" ]; then
		echo "Your installed python version, $(python3 --version), is too old."
		echo "Please update to at least $MIN_PYTHON_VERS."
		exit 1
	elif [ "$MAX_VERS" != "$MAX_PYTHON_VERS" ]; then
		echo "Your installed python version, $(python3 --version), is too new."
		echo "Please install $MAX_PYTHON_VERS."
		exit 1
	fi
}

pip_install () {
	if [ ! -d "./venv" ]; then
		# Some distros have venv built into python so this isn't always needed.
		if is_command 'apt-get'; then
			apt-get install -y python3-venv
		fi
		python3 -m venv ./venv
	fi
	source "${BASE_DIR}/venv/bin/activate"
	pip install --upgrade pip setuptools
	pip install -r "${BASE_DIR}/requirements.txt"
}

is_command() {
	command -v "${@}" > /dev/null
}

system_package_install() {
	PACKAGES=(aria2 git unzip wget)
	apt-get -y install ${PACKAGES[@]}
}

install_aid () {
	version_check
	pip_install
	system_package_install
}

install_aid