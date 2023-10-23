FROM eclipse-temurin:21-ubi9-minimal

MAINTAINER Tomasz Hawliczek <thawliczek@gmail.com>

ENV WILDFLY_VERSION  30.0.0.Final
ENV WILDFLY_SHA1     15f56267c97f1b4e422f56b771075a2ae586dd34
ENV JBOSS_HOME       /opt/wildfly

RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss

ADD run.sh /
ADD create_wildfly_admin_user.sh /

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -L -O https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && mkdir $JBOSS_HOME/standalone/data \
    && mkdir $JBOSS_HOME/standalone/log \
    && chown jboss:jboss $JAVA_HOME/lib/security/cacerts \
    && chmod +x /create_wildfly_admin_user.sh /run.sh \
    && chown -R jboss:0 ${JBOSS_HOME} \
   && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

EXPOSE 8080 9990 8443 9993 5005

USER jboss

RUN ls -Ralph $JBOSS_HOME/standalone

CMD ["/run.sh"]
