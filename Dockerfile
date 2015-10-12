FROM centos:centos6.7

MAINTAINER James McDonald james@jmits.com.au

# Init ENV
ENV BISERVER_VERSION 5.4
ENV BISERVER_TAG 5.4.0.1-130
ENV JDK jdk-7u80-linux-x64.rpm
ENV PENTAHO_HOME /opt/pentaho

# Apply JAVA_HOME

COPY scripts/java.sh /etc/profile.d/

RUN chmod +x /etc/profile.d/java.sh; \
	echo root:dockerroot | chpasswd; \
        useradd -m -s /bin/bash -d ${PENTAHO_HOME} pentaho 

ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_JAVA_HOME /usr/java/jdk1.7.0_80
ENV JAVA_HOME /usr/java/jdk1.7.0_80


# Download Pentaho BI Server
COPY files/biserver-ce-${BISERVER_TAG}.zip ${PENTAHO_HOME}/
COPY files/${JDK} ${PENTAHO_HOME}/

RUN yum -y localinstall ${PENTAHO_HOME}/${JDK} 

# Install Dependences
RUN yum install unzip zip which -y


USER pentaho


RUN /usr/bin/unzip -q ${PENTAHO_HOME}/biserver-ce-${BISERVER_TAG}.zip -d  ${PENTAHO_HOME}; \
    rm -f ${PENTAHO_HOME}/biserver-ce-${BISERVER_TAG}.zip $PENTAHO_HOME/biserver-ce/promptuser.sh; \
 sed -i -e 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/biserver-ce/tomcat/bin/startup.sh; \
    chmod +x $PENTAHO_HOME/biserver-ce/start-pentaho.sh 



COPY config $PENTAHO_HOME/config
COPY scripts $PENTAHO_HOME/scripts

WORKDIR /opt/pentaho 

CMD ["sh", "scripts/run.sh"]
