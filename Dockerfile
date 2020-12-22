FROM ubuntu:18.04

MAINTAINER OwenYang <coolsealtw@hotmail.com>

ENV MAVEN_VERSION=3.2.5
ENV JAVA_VERSION_MAJOR=6
ENV JAVA_VERSION_MINOR=45
ENV JAVA_VERSION_BUILD=45

ENV ANT_VERSION 1.9.4

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN apt update
RUN apt install wget -y

WORKDIR /tmp/apache-ant-${ANT_VERSION}
COPY ./apache-ant-${ANT_VERSION}-bin.tar.gz .

#RUN wget -q https://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
RUN tar -xzf apache-ant-${ANT_VERSION}-bin.tar.gz && \
    mv apache-ant-${ANT_VERSION} /opt/ant && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz

ENV ANT_HOME /opt/ant
ENV PATH ${PATH}:/opt/ant/bin

ENV JAVA_HOME /opt/java
ENV PATH $JAVA_HOME/bin:$PATH

RUN mkdir /tmp/java1.6.0_45
WORKDIR /tmp/java1.6.0_45

COPY ./jdk-6u45-linux-x64.bin .
RUN chmod +x jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.bin \
 && ./jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.bin \
 && rm jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.bin \
 && mv jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/oracle-jdk-1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} \
 && ln -s /opt/oracle-jdk-1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/java
