#!/usr/bin/env bash

STATE_FILE=/tmp/provision

function once() {
  if ! grep -q ${1} ${STATE_FILE}; then
    (${1}) && echo ${1} >> ${STATE_FILE}
  else
    echo "Skipping ${1} ..."
  fi
}

function prep() {
  wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
  sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
  add-apt-repository ppa:webupd8team/java
}

function update() {
  apt-get update -y && sudo apt-get upgrade -y
}

function jdk() {
  echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
  echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
  apt-get install -qq -y -o=Dpkg::Use-Pty=0 oracle-java8-installer
}

function jenkins() {
  apt-get install -y jenkins 
}

function git() {
  apt-get install -y git
}

function docker() {
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

  apt-get update
  apt-get install -y --force-yes docker-ce

  #usermod -a -G docker $USER
}

once prep
once update
once jdk
once jenkins
once git
once docker
