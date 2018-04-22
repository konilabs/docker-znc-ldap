FROM debian:stretch-slim
MAINTAINER Nicolas PERRIN "nicolas@perrin.in"

ENV ZNC_VERSION 1.6.4
ENV DATADIR /znc-data
ENV SSL_DOMAIN myznc.net

RUN apt-get update \
    && apt-get install -y sudo wget build-essential libssl-dev libperl-dev \
               pkg-config swig3.0 libicu-dev ca-certificates \
               libsasl2-dev python3-dev sasl2-bin supervisor \
    && mkdir -p /src \
    && cd /src \
    && wget "http://znc.in/releases/archive/znc-${ZNC_VERSION}.tar.gz" \
    && tar -zxf "znc-${ZNC_VERSION}.tar.gz" \
    && cd "znc-${ZNC_VERSION}" \
    && ./configure --enable-cyrus --enable-perl --enable-python --disable-ipv6 \
    && make \
    && make install \
    && apt-get remove -y wget \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /src* /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd znc
ADD docker-entrypoint.sh /entrypoint.sh
ADD znc.conf.default /znc.conf.default
ADD supervisord.conf /supervisord.conf
ADD saslauthd.conf.default /saslauthd.conf.default
RUN chmod 644 /znc.conf.default
RUN usermod -a -G sasl znc

VOLUME /znc-data

EXPOSE 1234
ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
