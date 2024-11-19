FROM eclipse-temurin:21-jdk

MAINTAINER Tomasz Hawliczek <thawliczek@gmail.com>

ENV WILDFLY_VERSION  26.1.3.Final
ENV WILDFLY_SHA1     b9f52ba41df890e09bb141d72947d2510caf758c
ENV JBOSS_HOME       /opt/wildfly

ADD run.sh /
ADD create_wildfly_admin_user.sh /

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -LOs https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && mkdir $JBOSS_HOME/standalone/data \
    && mkdir $JBOSS_HOME/standalone/log \
    && groupadd -r jboss -g 433 \
    && useradd -u 431 -r -g jboss -d $JBOSS_HOME -s /bin/false -c "WildFly user" jboss \
    && chown jboss:jboss $JAVA_HOME/lib/security/cacerts \
    && chmod +x /create_wildfly_admin_user.sh /run.sh \
    && chown -R jboss:jboss $JBOSS_HOME/

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

EXPOSE 8080 9990 8443 9993 5005

USER jboss

RUN ls -Ralph $JBOSS_HOME/standalone

CMD ["/run.sh"]
