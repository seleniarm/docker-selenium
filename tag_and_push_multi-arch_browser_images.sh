#!/usr/bin/env bash

VERSION=$1
BUILD_DATE=$2
NAMESPACE=$3
PUSH_IMAGE="${4:-false}"
BROWSER=$5
PLATFORMS=$6

TAG_VERSION=${VERSION}-${BUILD_DATE}

function short_version() {
    local __long_version=$1
    local __version_split=( ${__long_version//./ } )
    echo "${__version_split[0]}.${__version_split[1]}"
}


echo "Tagging images for browser ${BROWSER}, version ${VERSION}, build date ${BUILD_DATE}, namespace ${NAMESPACE}"

case "${BROWSER}" in

chromium)
  CHROMIUM_VERSION=$(docker run --rm seleniarm/node-chromium:${TAG_VERSION} chromium --version | awk '{print $2}')
  echo "Chromium version -> "${CHROMIUM_VERSION}
  CHROME_SHORT_VERSION="$(short_version ${CHROMIUM_VERSION})"
  echo "Short Chromium version -> "${CHROME_SHORT_VERSION}

  CHROMEDRIVER_VERSION=$(docker run --rm seleniarm/node-chromium:${TAG_VERSION} chromedriver --version | awk '{print $2}')
  echo "ChromeDriver version -> "${CHROMEDRIVER_VERSION}
  CHROMEDRIVER_SHORT_VERSION="$(short_version ${CHROMEDRIVER_VERSION})"
  echo "Short ChromeDriver version -> "${CHROMEDRIVER_SHORT_VERSION}

  CHROME_TAGS=(
      ${CHROMIUM_VERSION}-chromedriver-${CHROMEDRIVER_VERSION}-grid-${TAG_VERSION}
      # Browser version and browser driver version plus build date
      ${CHROMIUM_VERSION}-chromedriver-${CHROMEDRIVER_VERSION}-${BUILD_DATE}
      # Browser version and browser driver version
      ${CHROMIUM_VERSION}-chromedriver-${CHROMEDRIVER_VERSION}      
      # Browser version and build date
      ${CHROMIUM_VERSION}-${BUILD_DATE}
      # Browser version
      ${CHROMIUM_VERSION}      
      ## Short versions
      ${CHROME_SHORT_VERSION}-chromedriver-${CHROMEDRIVER_SHORT_VERSION}-grid-${TAG_VERSION}
      # Browser version and browser driver version plus build date
      ${CHROME_SHORT_VERSION}-chromedriver-${CHROMEDRIVER_SHORT_VERSION}-${BUILD_DATE}
      # Browser version and browser driver version
      ${CHROME_SHORT_VERSION}-chromedriver-${CHROMEDRIVER_SHORT_VERSION}      
      # Browser version and build date
      ${CHROME_SHORT_VERSION}-${BUILD_DATE}
      # Browser version
      ${CHROME_SHORT_VERSION}      
  )

  cd NodeChromium
  NODE_CHROMIUM_TAGS=""
  STANDALONE_CHROMIUM_TAGS=""
  for chrome_tag in "${CHROME_TAGS[@]}"
  do
    #docker tag ${NAMESPACE}/node-chromium:${TAG_VERSION} ${NAMESPACE}/node-chromium:${chrome_tag}
    #docker tag ${NAMESPACE}/standalone-chromium:${TAG_VERSION} ${NAMESPACE}/standalone-chromium:${chrome_tag}
    NODE_CHROMIUM_TAGS+=" -t ${NAME}/node-chromium:${chrome_tag}"
    STANDALONE_CHROMIUM_TAGS+=" -t ${NAME}/standalone-chromium:${chrome_tag}"
  done
  if [ "${PUSH_IMAGE}" = true ]; then
      cd ../NodeChromium && docker buildx build --platform ${PLATFORMS} --push ${NODE_CHROMIUM_TAGS} .
      cd ../StandaloneChromium && docker buildx build --platform ${PLATFORMS} --push ${STANDALONE_CHROMIUM_TAGS} .  
  fi
  
  ;;
firefox)
  FIREFOX_VERSION=$(docker run --rm seleniarm/node-firefox:${TAG_VERSION} firefox --version | awk '{print $3}')
  echo "Firefox version -> "${FIREFOX_VERSION}
  FIREFOX_SHORT_VERSION="$(short_version ${FIREFOX_VERSION})"
  echo "Short Firefox version -> "${FIREFOX_SHORT_VERSION}
  GECKODRIVER_VERSION=$(docker run --rm seleniarm/node-firefox:${TAG_VERSION} geckodriver --version | awk 'NR==1{print $2}')
  echo "GeckoDriver version -> "${GECKODRIVER_VERSION}
  GECKODRIVER_SHORT_VERSION="$(short_version ${GECKODRIVER_VERSION})"
  echo "Short GeckoDriver version -> "${GECKODRIVER_SHORT_VERSION}

  FIREFOX_TAGS=(
      ${FIREFOX_VERSION}-geckodriver-${GECKODRIVER_VERSION}-grid-${TAG_VERSION}
      # Browser version and browser driver version plus build date
      ${FIREFOX_VERSION}-geckodriver-${GECKODRIVER_VERSION}-${BUILD_DATE}
      # Browser version and browser driver version
      ${FIREFOX_VERSION}-geckodriver-${GECKODRIVER_VERSION}      
      # Browser version and build date
      ${FIREFOX_VERSION}-${BUILD_DATE}
      # Browser version
      ${FIREFOX_VERSION}      
      ## Short versions
      ${FIREFOX_SHORT_VERSION}-geckodriver-${GECKODRIVER_SHORT_VERSION}-grid-${TAG_VERSION}
      # Browser version and browser driver version plus build date
      ${FIREFOX_SHORT_VERSION}-geckodriver-${GECKODRIVER_SHORT_VERSION}-${BUILD_DATE}
      # Browser version and browser driver version
      ${FIREFOX_SHORT_VERSION}-geckodriver-${GECKODRIVER_SHORT_VERSION}      
      # Browser version and build date
      ${FIREFOX_SHORT_VERSION}-${BUILD_DATE}
      # Browser version
      ${FIREFOX_SHORT_VERSION}      
  )

  #cd NodeFirefox
  NODE_FIREFOX_TAGS=""
  STANDALONE_FIREFOX_TAGS=""
  for firefox_tag in "${FIREFOX_TAGS[@]}"
  do
    #docker tag ${NAMESPACE}/node-firefox:${TAG_VERSION} ${NAMESPACE}/node-firefox:${firefox_tag}
    #docker tag ${NAMESPACE}/standalone-firefox:${TAG_VERSION} ${NAMESPACE}/standalone-firefox:${firefox_tag}
    NODE_FIREFOX_TAGS+=" -t ${NAME}/node-firefox:${firefox_tag}"
    STANDALONE_FIREFOX_TAGS+=" -t ${NAME}/standalone-firefox:${firefox_tag}"
    if [ "${PUSH_IMAGE}" = true ]; then
        cd ../NodeFirefox && docker buildx build --platform ${PLATFORMS} --push ${NODE_FIREFOX_TAGS} .
        cd ../StandaloneFirefox && docker buildx build --platform ${PLATFORMS} --push ${STANDALONE_FIREFOX_TAGS} .
    fi
  done

  ;;
*)
  echo "Unknown browser!"
  ;;
esac