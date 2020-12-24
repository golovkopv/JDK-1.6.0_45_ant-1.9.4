#!/bin/bash
if [ -z "${BAMBOO_SERVER}" ]; then
	BAMBOO_SERVER="https://bamboo.bftcom.com"
fi

BAMBOO_AGENT=/opt/bamboo-agent/atlassian-bamboo-agent-installer.jar
echo "kubernetes=$1" >> /opt/bamboo-agent/bin/bamboo-capabilities.properties
if [ ! -f ${BAMBOO_AGENT} ]; then
	echo "Downloading agent JAR..."
	wget -v -O ${BAMBOO_AGENT} "${BAMBOO_SERVER}/agentServer/agentInstaller/" --ca-directory=/etc/pki/ca-trust/source/anchors/
	chmod 777 ${BAMBOO_AGENT}
	ls -la /opt/bamboo-agent/
fi

BAMBOO_SH=/opt/bamboo-agent/bin/bamboo-agent.sh
if [ ! -f $BAMBOO_SH ]; then
  # Run the agent installer
  echo "-> Running Bamboo Installer ..."
  java -Dbamboo.home=/opt/bamboo-agent -jar "${BAMBOO_AGENT}" "${BAMBOO_SERVER}/agentServer/" -t 06a29d852a5c680609123329c6530a11720f4b93
fi

# Run the Bamboo agent
$BAMBOO_SH console