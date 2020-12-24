FROM centos:centos7
LABEL name="CentOS 7" vendor="OOO BFT"
MAINTAINER Pavel V. Golovko

#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en

ENV SERVER_REPO="http://srv-nexus:8081" \
	TEMP_DIR="/opt/temp" \
	USER_HOME="/home/work-user" \
	JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
ENV PATH=${PATH}:${JAVA_HOME}/bin \
	CLASSPATH=.:${JAVA_HOME}/lib:${JAVA_HOME}/lib/tools.jar

#SSH-keys for local user "work-user"
ADD ${SERVER_REPO}/repository/files_for_devops/all_files/ssh/tester/id_rsa ${TEMP_DIR}/
ADD ${SERVER_REPO}/repository/files_for_devops/all_files/ssh/tester/id_rsa.pub ${TEMP_DIR}/
ADD ${SERVER_REPO}/repository/files_for_devops/all_files/ssh/tester/known_hosts ${TEMP_DIR}/

#Fonts for centos 7
ADD ${SERVER_REPO}/repository/files_for_devops/all_files/msttcore-fonts-2.0-2.noarch.rpm ${TEMP_DIR}/
#Git config
ADD ./.gitconfig ${TEMP_DIR}/
#Bamboo files
ADD bamboo-agent.sh /opt/
ADD bamboo-capabilities.properties /opt/bamboo-agent/bin/bamboo-capabilities.properties

#Delete default repositories, install srv-nexus repository
RUN rm -f /etc/yum.repos.d/* && \
    touch /etc/yum.repos.d/srv-nexus.repo && \
    echo "[nexusrepo]" >> /etc/yum.repos.d/srv-nexus.repo && \
    echo "name=Nexus Repository" >> /etc/yum.repos.d/srv-nexus.repo && \
    echo "baseurl=http://srv-nexus:8081/repository/yum-nexus-group-cos7/" >> /etc/yum.repos.d/srv-nexus.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/srv-nexus.repo && \
    echo "gpgcheck=0" >> /etc/yum.repos.d/srv-nexus.repo && \
    echo "priority=1" >> /etc/yum.repos.d/srv-nexus.repo && \
#Yum upgrade
    yum makecache && \
    yum upgrade -y && \
#Install fonts
    yum install -y ${TEMP_DIR}/msttcore-fonts-2.0-2.noarch.rpm && \
#Language settings
    localedef -i ru_RU -f UTF-8 ru_RU.UTF-8 && \
    echo "LANG=\"ru_RU.UTF-8\"" > /etc/locale.conf && \
    echo -e 'LANG="ru_RU.UTF-8"\nSUPPORTED="ru_RU.UTF-8:ru_RU:ru"\nSYSFONT="latarcyrheb-sun16"' > /etc/sysconfig/i18n && \
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
#Create user
    groupadd -r -g 900 work-user && \
    useradd -r -m -u 900 -g 900 work-user && \
#Add ssh keys to user
    mkdir -p ${USER_HOME}/.ssh && \
    cp -f ${TEMP_DIR}/id_rsa ${USER_HOME}/.ssh/id_rsa && \
    cp -f ${TEMP_DIR}/id_rsa.pub ${USER_HOME}/.ssh/id_rsa.pub && \
    cp -f ${TEMP_DIR}/known_hosts ${USER_HOME}/.ssh/known_hosts && \
    chown -R work-user:work-user ${USER_HOME}/.ssh && \
    chmod 700 ${USER_HOME}/.ssh && \
    chmod 644 ${USER_HOME}/.ssh/* && \
    chmod 600 ${USER_HOME}/.ssh/id_rsa && \
#Install utilites
    yum -y install unzip mc curl wget && \
#Install OpenJDK 8
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel java-1.6.0-openjdk java-1.6.0-openjdk-devel and && \
#Install git
    yum -y install git && \
    cp -f ${TEMP_DIR}/.gitconfig ${USER_HOME}/.gitconfig && \
#Install bamboo-agent
    chown -R work-user:work-user /opt && \
    chmod -R 777 /opt && \
    echo "system.jdk.JDK\ 8=${JAVA_HOME}" >> /opt/bamboo-agent/bin/bamboo-capabilities.properties && \
#Clean all cache
    yum clean all && rm -rf /var/cache/yum/ && \
    rm -rf ${TEMP_DIR}
ENV LC_ALL="ru_RU.UTF-8" \
    LANG="ru_RU.UTF-8" \
    LANGUAGE="ru_RU.UTF-8"

USER work-user
WORKDIR /opt
CMD ["/opt/bamboo-agent.sh"]
