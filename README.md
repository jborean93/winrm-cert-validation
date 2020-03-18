# Ansible WinRM Cert Validation Testing

This repo is designed to test out certificate validation for HTTPS WinRM endpoints and how to import a CA trust cert
into distro specific stores.

## Requirements

* Ansible
* Vagrant
* Docker

## Setup

To set up the Windows host and CA certificates run `vagrant up`.

To set up the test container for each distro run

* `docker build -f centos7/Dockerfile .`
