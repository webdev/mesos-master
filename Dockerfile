FROM ubuntu:14.04
MAINTAINER George Blazer

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# Make sure to install OpenJDK 6 explicitly.  The libmesos l&ibrary includes an
# RPATH entry, which is needed to find libjvm.so at runtime.  This RPATH is
# hard-coded to the OpenJDK version that was present when the package was
# compiled.  So even though the Debian package claims that it works with either
# OpenJDK 6 or OpenJDK 7, the fact that Mesosphere compiled with OpenJDK 6 means
# that we have to have that specific version present at runtime.

# Mesos stuff
WORKDIR /tmp
RUN \
  apt-get install -y curl openjdk-6-jre-headless && \
  curl -O https://downloads.mesosphere.io/master/ubuntu/14.04/mesos_0.20.1-1.0.ubuntu1404_amd64.deb && \
  dpkg --unpack mesos_0.20.1-1.0.ubuntu1404_amd64.deb && \
  apt-get install -f -y && \
  rm mesos_0.20.1-1.0.ubuntu1404_amd64.deb && \
  apt-get clean

# Golang stuff
# From docker-library/golang
RUN apt-get install -y \
		ca-certificates curl gcc libc6-dev make \
		bzr git mercurial \
		--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*
	
ENV GOLANG_VERSION 1.3.3

RUN curl -sSL https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz \
		| tar -v -C /usr/src -xz

RUN cd /usr/src/go/src && ./make.bash --no-clean 2>&1

ENV PATH /usr/src/go/bin:$PATH

RUN mkdir -p /go/src
ENV GOPATH /go
ENV PATH /go/bin:$PATH
WORKDIR /go

# Mesos-Go
RUN apt-get update && apt-get install -y libprotobuf-dev g++
RUN go get code.google.com/p/goprotobuf/proto
RUN go get code.google.com/p/goprotobuf/protoc-gen-go

RUN go get github.com/mesosphere/mesos-go/example_framework
RUN go get github.com/mesosphere/mesos-go/example_executor

EXPOSE 5050
CMD ["mesos-master"]