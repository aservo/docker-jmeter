# -----------------------------------------------------------------------
# JMeter base layer
# inspired by https://hub.docker.com/r/justb4/jmeter
# -----------------------------------------------------------------------
FROM alpine:3.15.0 as jmeter-base

LABEL maintainer="klehmann@aservo.com"

ARG JMETER_VERSION="5.4.2"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV JMETER_PLUGINS_FOLDER ${JMETER_HOME}/lib/ext/
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# Install extra packages
# See https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-272703023
ARG TZ="Europe/Amsterdam"
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Entrypoint has same signature as "jmeter" command
COPY entrypoint.sh /
WORKDIR	${JMETER_HOME}
ENTRYPOINT ["/entrypoint.sh"]

# -----------------------------------------------------------------------
# JMeter layer including plugins
# inspired by https://hub.docker.com/r/egaillardon/jmeter-plugins/
# -----------------------------------------------------------------------
FROM jmeter-base

ARG JMETER_PLUGINS_MANAGER_VERSION=1.7
ARG CMDRUNNER_VERSION=2.2
ARG PROMETHEUS_LISTERER_VERSION=0.6.0

# install plugins not provided via plugin manager manually
RUN curl -L --silent https://repo1.maven.org/maven2/com/github/johrstrom/jmeter-prometheus-plugin/${PROMETHEUS_LISTERER_VERSION}/jmeter-prometheus-plugin-${PROMETHEUS_LISTERER_VERSION}.jar -o ${JMETER_PLUGINS_FOLDER}/jmeter-prometheus-plugin-${PROMETHEUS_LISTERER_VERSION}.jar

# prometheus listener port
EXPOSE 9270

# install plugins via plugin manager (note: list of plugin ids can be retrieved with 'PluginsManagerCMD.sh status')
RUN cd /tmp/ \
 && curl --location --silent --show-error --output ${JMETER_PLUGINS_FOLDER}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar http://search.maven.org/remotecontent?filepath=kg/apc/jmeter-plugins-manager/${JMETER_PLUGINS_MANAGER_VERSION}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar \
 && curl --location --silent --show-error --output ${JMETER_HOME}/lib/cmdrunner-${CMDRUNNER_VERSION}.jar http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/${CMDRUNNER_VERSION}/cmdrunner-${CMDRUNNER_VERSION}.jar \
 && java -cp ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
 && PluginsManagerCMD.sh install jpgc-graphs-basic=2.0,jpgc-prmctl=0.4,jpgc-dummy=0.4,jpgc-functions=2.1 \
 && jmeter --version \
 && PluginsManagerCMD.sh status \
 && chmod +x ${JMETER_HOME}/bin/*.sh \
 && rm -fr /tmp/*