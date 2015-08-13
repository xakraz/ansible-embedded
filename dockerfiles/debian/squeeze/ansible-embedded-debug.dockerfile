FROM ansible-embedded-base:squeeze

RUN apt-get update -qq \
 && apt-get install -y --force-yes openssh-client \
 && apt-get clean \
 && rm -rf /var/lib/apt/list* \
  /tmp/* \
  /var/tmp/*
