FROM ansible-embedded-base:wheezy

RUN apt-get update -qq \
 && apt-get install -y openssh-client \
 && apt-get clean \
 && rm -rf /var/lib/apt/list* \
  /tmp/* \
  /var/tmp/*
