ARG NAMESPACE
ARG VERSION
ARG AUTHORS
FROM ${NAMESPACE}/node-base:${VERSION}
LABEL authors=${AUTHORS}

ARG TARGETARCH
ARG TARGETVARIANT

USER root

#=========
# Firefox
# Available versions at https://launchpad.net/~mozillateam/+archive/ubuntu/ppa
#=========
ARG FIREFOX_VERSION=121.0+build1-0ubuntu0.22.04.1~mt1
RUN apt-get -qqy update \
  && apt-get -qqy install libavcodec-extra software-properties-common \
  && add-apt-repository ppa:mozillateam/ppa \
  && apt-get -qqy update \
  && apt-get -qqy install -t 'o=LP-PPA-mozillateam' firefox=${FIREFOX_VERSION} \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#============
# GeckoDriver
#============
ARG GECKODRIVER_VERSION=latest
RUN GK_VERSION=$(if [ ${GECKODRIVER_VERSION:-latest} = "latest" ]; then echo "0.33.0"; else echo $GECKODRIVER_VERSION; fi) \
  && echo "Using GeckoDriver version: "$GK_VERSION \
  && if [ $TARGETARCH = "arm" ] && [ $TARGETVARIANT = "v7" ]; then \
     ARCH=armhf ; \
  else \
     ARCH=$TARGETARCH ; \
  fi \
  && if [ -z "$ARCH" ]; then \
     echo "*** BUILD ERROR: \$TARGETARCH must be arm64, amd64, or arm with \$TARGETVARIANT set to v7... exiting..." ; \
     exit 1 ; \
  fi \
  && if [ "$ARCH" = "arm64" ]; then \
     GK_DOWNLOAD_URL="https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux-aarch64.tar.gz" ; \
  elif [ "$ARCH" = "armhf" ]; then \
     GK_DOWNLOAD_URL="https://github.com/jamesmortensen/geckodriver-arm-binaries/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux-armv7l.tar.gz" ; \
  else \
     GK_DOWNLOAD_URL="https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux64.tar.gz" ; \
  fi \
  && wget --no-verbose -O /tmp/geckodriver.tar.gz $GK_DOWNLOAD_URL \
  && rm -rf /opt/geckodriver \
  && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
  && rm /tmp/geckodriver.tar.gz \
  && mv /opt/geckodriver /opt/geckodriver-$GK_VERSION \
  && chmod 755 /opt/geckodriver-$GK_VERSION \
  && ln -fs /opt/geckodriver-$GK_VERSION /usr/bin/geckodriver

# Workaround for issue launch Firefox Webdriver "Failed to read marionette port"
RUN mkdir -p /home/seluser/.cache /home/seluser/.mozilla /.cache \
    && chmod 777 /home/seluser/.cache /home/seluser/.mozilla /.cache

USER 1200

RUN if ! whoami &> /dev/null; then \
  if [ -w /tmp/passwd ]; then \
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:/home/seluser:/tmp:/bin/bash" >> /tmp/passwd; \
  fi \
fi

#============================================
# Dumping Browser information for config
#============================================
RUN echo "firefox" > /opt/selenium/browser_name
RUN firefox --version | awk '{print $3}' > /opt/selenium/browser_version
RUN echo "\"moz:firefoxOptions\": {\"binary\": \"/usr/bin/firefox\"}" > /opt/selenium/browser_binary_location
