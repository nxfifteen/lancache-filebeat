#!/bin/bash

# Exit if there is an error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# If there is an .env file use it
# to set the variables
if [ -f $SCRIPT_DIR/.env ]; then
    source $SCRIPT_DIR/.env
fi

# Check all required variables are set
: "${CACHE_LOGS_DIRECTORY:?must be set}"
: "${LOGSTASH_HOST:?must be set}"

# Add elastic apt repo if it does not already exist
if [[ ! -f /etc/apt/sources.list.d/elastic-6.x.list ]]; then
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
fi

# Install the key for the elastic repo
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Install required packages
/usr/bin/apt update -y
/usr/bin/apt install -y apt-transport-https \
                        filebeat

# Install the filebeat config file
/usr/bin/envsubst '$LOGSTASH_HOST $CACHE_LOGS_DIRECTORY' < "$SCRIPT_DIR/configs/filebeat.yml.templ" > "/etc/filebeat/filebeat.yml"

# Set filebeat to run at boot
# /bin/systemctl enable filebeat

# Start filebeat
# /bin/systemctl start filebeat
