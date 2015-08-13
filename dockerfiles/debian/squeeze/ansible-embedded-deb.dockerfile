FROM ansible-embedded-base:squeeze
MAINTAINER Xavier Krantz <xakraz@gmail.com>


RUN apt-get update -qq \
 && apt-get install -y fakeroot \
 && apt-get clean \
 && rm -rf /var/lib/apt/list* \
  /tmp/* \
  /var/tmp/*

COPY tools/package.sh /usr/local/bin/

CMD ["package.sh"]
