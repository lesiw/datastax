FROM ubuntu

ARG DSE_VERSION=6.9

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DSE_HOME=/opt/dse
ENV CASSANDRA_CONF=/opt/dse/resources/cassandra/conf
ENV CASSANDRA_CONFIG=/opt/dse/resources/cassandra/conf/cassandra.yaml
ENV CASSANDRA_RACK_CONFIG=/opt/dse/resources/cassandra/conf/cassandra-rackdc.properties
ENV NATIVE_TRANSPORT_ADDRESS="0.0.0.0"
ENV SNITCH=GossipingPropertyFileSnitch
ENV PATH=/opt/dse/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
        adduser \
        curl \
        debianutils \
        gzip \
        htop \
        iperf3 \
        iputils-ping \
        less \
        libjansi-java \
        libjansi-native-java \
        libjemalloc2 \
        locales \
        lsb-base \
        nano \
        net-tools \
        netcat-openbsd \
        openjdk-11-jdk \
        patch \
        procps \
        python3 \
        socat \
        sudo \
        sysstat \
        tini \
        wget \
        zlib1g \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r --gid=999 dse \
    && useradd -M -d "$DSE_HOME" -r -g dse -G root --uid=999 dse \
    && cd /opt \
    && wget -q -O- \
        "https://downloads.datastax.com/enterprise/dse-$DSE_VERSION.tar.gz" \
        | tar xz \
    && ls -alh /opt \
    && mv /opt/dse*/ /opt/dse \
    && chown -R dse:root /opt/dse \
    && chmod 750 /opt/dse \
    && (for dir in \
        /config \
        /var/lib/cassandra \
        /var/lib/datastax-agent \
        /var/lib/dsefs \
        /var/lib/spark \
        /var/log/cassandra \
        /var/log/spark \
    ; do mkdir -p "$dir" && chown -R dse:root "$dir"; done) \
    && chmod g+w "$DSE_HOME"

COPY entrypoint.sh /entrypoint.sh
USER dse
WORKDIR /opt/dse
ENTRYPOINT ["/entrypoint.sh", "dse", "cassandra", "-f"]
VOLUME [/var/lib/cassandra /var/lib/spark /var/lib/dsefs /var/log/cassandra /var/log/spark]

EXPOSE 7000 7001 7199 8609 9042 9160
EXPOSE 8983 8984
EXPOSE 18080 4040 7077 7080 7081 8090 9999
EXPOSE 8182
EXPOSE 5598 5599
EXPOSE 10000
EXPOSE 9103
