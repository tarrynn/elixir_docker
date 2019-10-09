FROM ubuntu:16.04

# Centralize here apt setup to just run 'apt-get update' at the beginning instead of
# once before every install command:

RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends wget

RUN apt-get install -y --no-install-recommends \
       python3 python3-dev python3-setuptools fakeroot ca-certificates tar gzip zip \
       autoconf automake bzip2 file g++ gcc imagemagick libbz2-dev libc6-dev libcurl4-openssl-dev \
       libdb-dev libevent-dev libffi-dev libgeoip-dev libglib2.0-dev libjpeg-dev libkrb5-dev \
       liblzma-dev libmagickcore-dev libmagickwand-dev libmysqlclient-dev libncurses-dev libpng-dev \
       libpq-dev libreadline-dev libsqlite3-dev libssl-dev libtool libwebp-dev libxml2-dev libxslt-dev \
       libyaml-dev make patch xz-utils zlib1g-dev unzip curl git gnupg2 lsb-core

RUN curl -O https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py

RUN pip install awscli --upgrade --user

RUN ln -s ~/.local/bin/aws /usr/bin/aws

RUN aws --version

RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

RUN sudo apt-get -y install openssh-client

RUN wget -O /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && sudo chmod +x /usr/bin/jq

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && echo "Europe/Dublin" > /etc/timezone && apt-get -y install tzdata && dpkg-reconfigure -f noninteractive tzdata

RUN sudo apt-get -y install cmake

# NodeJs and NPM
# needed to process the httpS source from above:
RUN apt-get update && apt-get -y install apt-transport-https
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

# Elixir
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update && apt-get install -y esl-erlang
RUN apt-get update && apt-get install -y elixir

# Postgres
RUN sudo apt-get -y install postgresql-9.6 postgresql-contrib-9.6
ADD postgresql.conf /tmp/
RUN mv /tmp/postgresql.conf /var/lib/postgresql/9.6/main/postgresql.conf
RUN sudo chown -R postgres /var/lib/postgresql
