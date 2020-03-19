# Ansible WinRM Cert Validation Testing

This repo is designed to test out certificate validation for HTTPS WinRM endpoints and how to import a CA trust cert into distro specific stores.

## Overview

Getting Ansible to trust a WinRM certificate for both the [winrm](https://docs.ansible.com/ansible/latest/plugins/connection/winrm.html) and [psrp](https://docs.ansible.com/ansible/latest/plugins/connection/psrp.html) is done in the [requests](https://requests.readthedocs.io/en/master/) Python library. By default the requests library sources its trusted certs from the [certifi](https://github.com/certifi/python-certifi) Python library which does not use the system trust store for cert verification. This means that Ansible will not implicitly trust a WinRM certificate if the issue has been trusted on the host.

_TODO: Investigate requests.utils.DEFAULT_CA_BUNDLE_PATH._
_TODO: Verify whether certifi can use the system library._

All is not lost and I've created this repo to try and navigate through the various distro specific options and paths to create a detailed guide on how to get cert verification happening for WinRM in Ansible. The end result is that the following variable need to be set for the specific connection plugin used

* `winrm` -> `ansible_winrm_ca_trust_path`
* `psrp` -> `ansible_psrp_ca_cert`

These variable can either be set to an absolute path of a CA chain that is PEM encoded or a directory that has been prepared with the [c_rehash](https://www.openssl.org/docs/man1.0.2/man1/c_rehash.html) command from OpenSSL. This leaves you with 4 options when it comes to trusting a specific CA chain for WinRM on Ansible.

* Append your CA chain to the `certifi` package certs and let the defaults roll
    * This is **NOT** recommended as your certs will be removed once the package is upgraded (almost a certainty)
* Specify the absolute path to your exported CA chain with the variable specific above
    * This works just fine and is distro agnostic, you just need to ensure you have the cert chain available on the Ansible controller
* Specify the absolute path to the distro specific cert bundle file
    * This is like the option above but now the CA chain is loaded into the system trust store allowing other applications to use it
    * An enterprise environment could also be including their issuring cert saving you a step
* Specify the absolute path to the distro specific cert directory
    * Like the above but you just specify the dir, requires the dir to be run with `c_rehash` but you can keep the cert separate from the main bundle if you wish

While the paths and commands run differ per distro the basic workflow for the 3rd and 4th option are as follows

* Copy the certificate to a distro specific import path
* Run a distro specific command to synchronize the certs with the system store - this will read all the certs in the import path and place them in various locations on the host for all applications to use
* If you want to target a directory, run `c_rehash` to set up the system directory properly

A breakdown of each distro, it's input path, synchronization command, and final output paths are

| Distro | Input Path | Sync Command | File Path | Dir Path |
|--------|-------------------------------------------------------------------|-------------------------|------------------------------------|--------------------|
| Centos | /etc/pki/ca-trust/source/anchors | update-ca-trust extract | /etc/pki/tls/certs/ca-bundle.crt | /etc/pki/tls/certs |
| Ubuntu | /usr/local/share/ca-certificates¹ | update-ca-certificates | /etc/ssl/certs/ca-certificates.crt | /etc/ssl/certs² |

*1* - Copied file must have the extension `.crt` but can be a PEM encoded cert
*2* - The Python version included with Ubuntu 14.04 does not support dirs as a trust path

## Requirements

* Ansible
* Vagrant
* Docker

## Setup

To set up the Windows host and CA certificates run `vagrant up`.

To set up the test container for each distro run

* `docker build -f centos7/Dockerfile .`
* `docker build -f centos8/Dockerfile .`
* `docker build -f ubuntu1404/Dockerfile .`

In each contain you can run the following to test the various scenarios for trusting a cert

```bash
# For the WinRM connection plugin
ansible -i inventory.ini winrm_file -m win_ping
ansible -i inventory.ini winrm_system_file -m win_ping
ansible -i inventory.ini winrm_system_dir -m win_ping

# For the PSRP connection plugin
ansible -i inventory.ini psrp_file -m win_ping
ansible -i inventory.ini psrp_system_file -m win_ping
ansible -i inventory.ini psrp_system_dir -m win_ping
```

These are the scenarios it tests for each connection plugin

* `*_file`: Absolute path to the CA chain that is not on the trusted store
* `*_system_file`: Absolute path to the distro specific system trust store file
* `*_system_dir`: Absolute path to the distro specific system trust store directory
