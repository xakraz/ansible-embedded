FROM google/debian:wheezy


## 0 - Prep
## --
# remove several traces of debian python
RUN echo "===> Python: Remove Debian Python packages:" \
 && apt-get purge -y python.*

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

RUN echo "===> Python: Installing Dependencies:" \
 && apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  libsqlite3-0 \
  libssl1.0.0 \
 && rm -rf /var/lib/apt/lists/*

# gpg: key 18ADD4FF: public key "Benjamin Peterson <benjamin@python.org>" imported
RUN echo "===> Python: Install GPG key to check the python SRC tarball:" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF



## 1 - Install configuration
## --
ENV PYTHON_VERSION 2.7.10

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 7.1.0
ENV INSTALL_DIR /opt/ansible/1.9
ENV ANSIBLE_VERSION 1.9.2



## 2 - Compile Embedded Python
## --
RUN echo "===> Python: Install Python Build dependencies: " \
 && set -x \
 && buildDeps=' \
  curl \
  gcc \
  libbz2-dev \
  libc6-dev \
  libncurses-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  make \
  xz-utils \
  zlib1g-dev \
  ' \
 && apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
 && echo "===> Python: Getting the sources" \
 && mkdir -p /usr/src/python \
 && curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
 && curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
 && gpg --verify python.tar.xz.asc \
 && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
 && rm python.tar.xz* \
 && cd /usr/src/python \
 && echo "===> Python: Configure: " \
 && ./configure --enable-unicode=ucs4 --prefix $INSTALL_DIR \
 && echo "===> Python: Compile: " \
 && make -j$(nproc) \
 && make install \
 && ldconfig

ENV PATH ${INSTALL_DIR}/bin:${PATH}
RUN echo "===> Python: Install PIP: " \
 && curl -SL 'https://bootstrap.pypa.io/get-pip.py' | python2 \
 && pip install --no-cache-dir --upgrade pip==$PYTHON_PIP_VERSION

RUN echo "===> Python: FINAL: Clean the mess" \
 && find $INSTALL_DIR \
  \( -type d -a -name test -o -name tests \) \
  -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
  -exec rm -rf '{}' + \
 && apt-get purge -y --auto-remove $buildDeps \
 && rm -rf /usr/src/python



## 3 - Install Ansible
## --
RUN echo "===> Ansible: Install Ansible" \
 && pip install \
  ansible==${ANSIBLE_VERSION} \
  httplib2 \
  prettytable \
  python-consul



CMD ["/bin/bash"]
