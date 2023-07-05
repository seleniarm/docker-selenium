ARG NAMESPACE
ARG VERSION
ARG AUTHORS
FROM ${NAMESPACE}/node-base:${VERSION}
LABEL authors=${AUTHORS}

USER root

# Add Debian Sid sources and signing keys to install Chromium without snap
RUN wget -O debian-archive-keyring.deb \
  https://deb.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2023.3_all.deb \
  && dpkg -i debian-archive-keyring.deb \
  && apt-key update \
  && echo "deb http://deb.debian.org/debian/ unstable main contrib non-free" > /etc/apt/sources.list.d/debian.list \
  && echo "deb-src http://deb.debian.org/debian/ unstable main contrib non-free" >> /etc/apt/sources.list.d/debian.list

# Install Chromium 
RUN apt-get update -qqy \
  # && apt-get -qqy install chromium=89.0.4389.82-1 \
  # && apt-get -qqy install chromium=90.0.4430.212-1 \
  # && apt-get -qqy install chromium=93.0.4577.82-1 \
  # && apt-get -qqy install chromium=97.0.4692.71-0.1 \
  # && apt-get -qqy install chromium=98.0.4758.102-1+b1 \
  && apt-get -qqy install chromium \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#=================================
# Chromium Launch Script Wrapper
#=================================
COPY wrap_chromium_binary /opt/bin/wrap_chromium_binary
RUN /opt/bin/wrap_chromium_binary

#============================================
# Chromium webdriver
#============================================
RUN apt-get update -qqy \
  && apt-get -qqy install chromium-driver \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN echo "chromium" > /opt/selenium/browser_name

USER 1200

