ARG NAMESPACE
ARG VERSION
ARG AUTHORS
FROM ${NAMESPACE}/node-base:${VERSION}
LABEL authors=${AUTHORS}

USER root

#============================================
# Chromium and chromedriver from Debian
#============================================
ARG DEBIAN_VERSION=bullseye
RUN echo "deb [signed-by=/usr/share/keyrings/debian-${DEBIAN_VERSION}.gpg] http://deb.debian.org/debian ${DEBIAN_VERSION} main" > /etc/apt/sources.list.d/debian.list \
  && echo "deb [signed-by=/usr/share/keyrings/debian-${DEBIAN_VERSION}-updates.gpg] http://deb.debian.org/debian ${DEBIAN_VERSION}-updates main" >> /etc/apt/sources.list.d/debian.list \
  && echo "deb [signed-by=/usr/share/keyrings/debian-security-${DEBIAN_VERSION}.gpg] http://deb.debian.org/debian-security ${DEBIAN_VERSION}-security main contrib non-free" >> /etc/apt/sources.list.d/debian.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9 \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 112695A0E562B32A \
  && apt-key export 386FA1D9 | sudo gpg --dearmour -o /usr/share/keyrings/debian-${DEBIAN_VERSION}.gpg \
  && apt-key export 2643E131 | sudo gpg --dearmour -o /usr/share/keyrings/debian-${DEBIAN_VERSION}-updates.gpg \
  && apt-key export E562B32A | sudo gpg --dearmour -o /usr/share/keyrings/debian-security-${DEBIAN_VERSION}.gpg

COPY chromium.pref /etc/apt/preferences.d/chromium.pref

RUN apt-get update -qqy \
  && apt-get -qqy install chromium chromium-driver \
  && rm /etc/apt/sources.list.d/debian.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#=================================
# Chrome Launch Script Wrapper
#=================================
COPY wrap_chrome_binary /opt/bin/wrap_chrome_binary
RUN /opt/bin/wrap_chrome_binary

USER 1200

#============================================
# Dumping Browser information for config
#============================================
RUN echo "chrome" > /opt/selenium/browser_name
RUN chromium --version | awk '{print $2}' > /opt/selenium/browser_version
RUN echo "\"goog:chromeOptions\": {\"binary\": \"/usr/bin/chromium\"}" > /opt/selenium/browser_binary_location
