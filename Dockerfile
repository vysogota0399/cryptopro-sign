# Базовый образ с КриптоПро
#FROM debian:stretch-slim as cryptopro-generic
FROM ruby:3.2.4 as cryptopro-generic
# FROM ruby:latest as cryptopro-generic

# Устанавливаем timezone
ENV TZ="Europe/Moscow" \
    docker="1"

ARG LICENSE
ENV LICENSE ${LICENSE}

# prod или test
ARG ESIA_ENVIRONMENT='test'
ENV ESIA_CORE_CERT_FILE "/cryptopro/esia/esia_${ESIA_ENVIRONMENT}.cer"
ENV ESIA_PUB_KEY_FILE "/cryptopro/esia/esia_${ESIA_ENVIRONMENT}.pub"

ARG CERTIFICATE_PIN
ENV CERTIFICATE_PIN ${CERTIFICATE_PIN}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

ADD cryptopro/install /tmp/src
RUN cd /tmp/src && \
    tar -xf linux-amd64_deb.tgz && \
    linux-amd64_deb/install.sh && \
    # делаем симлинки
    cd /bin && \
    ln -s /opt/cprocsp/bin/amd64/certmgr && \
    ln -s /opt/cprocsp/bin/amd64/cpverify && \
    ln -s /opt/cprocsp/bin/amd64/cryptcp && \
    ln -s /opt/cprocsp/bin/amd64/csptest && \
    ln -s /opt/cprocsp/bin/amd64/csptestf && \
    ln -s /opt/cprocsp/bin/amd64/der2xer && \
    ln -s /opt/cprocsp/bin/amd64/inittst && \
    ln -s /opt/cprocsp/bin/amd64/wipefile && \
    ln -s /opt/cprocsp/sbin/amd64/cpconfig && \
    # прибираемся
    rm -rf /tmp/src

RUN apt-get update && apt-get install -y --no-install-recommends expect libboost-dev unzip g++ curl

ADD cryptopro/scripts /cryptopro/scripts
ADD cryptopro/certificates /cryptopro/certificates
ADD cryptopro/esia cryptopro/esia

FROM cryptopro-generic as configured-cryptopro

# устанавливаем лицензию, если она указана
RUN ./cryptopro/scripts/setup_license ${LICENSE}

# Устанавливаем корневой сертификат есиа
RUN ./cryptopro/scripts/setup_root ${ESIA_CORE_CERT_FILE}

# Устанавливаем сертификат пользователя
RUN ./cryptopro/scripts/setup_my_certificate /cryptopro/certificates/certificate_bundle.zip ${CERTIFICATE_PIN}

FROM configured-cryptopro

ARG app_path=/usr/src/app

WORKDIR ${app_path}
COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .