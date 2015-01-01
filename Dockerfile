FROM peenuty/rails-passenger-nginx-docker-i:1.0.1
MAINTAINER Mike Rapadas <mike@mrap.me>

# Install Node

    # GET NODE INSTALL DEPS
    RUN       apt-get update --fix-missing
    RUN       apt-get install -y build-essential python wget

    ENV 			NODE_VERSION 0.10.26

    RUN       wget http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz
    RUN       tar -zxvf node-v$NODE_VERSION.tar.gz
    RUN       rm node-v$NODE_VERSION.tar.gz
    WORKDIR   node-v0.10.26

    # INSTALL NODE
    RUN       ./configure
    RUN       make
    RUN       make install

    # CLEAN UP
    WORKDIR   ..
    RUN       rm -r node-v$NODE_VERSION
    RUN       apt-get remove -y build-essential python wget

# Grunt needs git
    RUN apt-get -y install git

# Install Sass

    RUN bash -l -c "gem install sass"

# Install grunt
    RUN npm install -g grunt-cli

# Install Bower
    RUN npm install -g bower


# Setup Go
#
# Go Dockerfile
#
# https://github.com/dockerfile/go
#

# Install Go
RUN apt-get install -y curl
RUN \
  mkdir -p /goroot && \
  curl https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

# Set environment variables.
ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

# Install Godep
RUN apt-get install -y mercurial
RUN go get github.com/tools/godep
ADD . /gopath/src/github.com/mrap/combo

# Setup Project
# Define working directory.
WORKDIR /gopath/src/github.com/mrap/combo

# Prepare frontend files
RUN npm install
# manually npm install grunt-sass to ensure libsass bindings
RUN npm install grunt-sass
RUN bower --allow-root install
RUN grunt

# Install go deps
RUN godep restore

RUN go install

ENTRYPOINT combo
EXPOSE 8000

