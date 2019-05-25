FROM majid7221/java:oracle-11

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Req
RUN set -ex \
    && apt-get update \
    && apt-get install -y ttf-dejavu fontconfig \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

RUN set -ex \
    && groupadd jenkins \
    && useradd -d "$JENKINS_HOME" -m -s /bin/bash -g jenkins jenkins \
    && chown jenkins:jenkins $JENKINS_HOME

VOLUME $JENKINS_HOME

RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
COPY files/init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

ENV JENKINS_VERSION 2.164.3

ENV JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

RUN set -ex \
    && curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war

RUN chown -R jenkins:jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# Install docker
RUN set -ex \
    && curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey \
    && echo  "deb [arch=amd64] http://download.docker.com/linux/debian stretch stable" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get -y install docker-ce \
    && usermod -a -G docker jenkins \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# http port
EXPOSE 8080
# agent port
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

RUN ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1
ENV LD_LIBRARY_PATH=/usr/lib

COPY files/jenkins-support /usr/local/bin/jenkins-support
COPY files/jenkins.sh /usr/local/bin/jenkins.sh
ENTRYPOINT ["/usr/bin/dumb-init", "-cv" ,"/usr/local/bin/jenkins.sh"]