# Ansible WinRM Cert Validation Testing

This repo is designed to test out certificate validation for HTTPS WinRM endpoints and the default paths and configs for
specific distros when it comes to system wide trust stores.


## Overview

Getting Ansible to trust a WinRM certificate for both the
[winrm](https://docs.ansible.com/ansible/latest/plugins/connection/winrm.html) and
[psrp](https://docs.ansible.com/ansible/latest/plugins/connection/psrp.html) is done in the
[requests](https://requests.readthedocs.io/en/master/) Python library. By default the requests library sources its
trusted certs from the [certifi](https://github.com/certifi/python-certifi) Python library but installing requests from
a distro specific package like `yum install python-requests` are configured to use the system store. This means that
the cert trust location for WinRM in Ansible changes based on a myriad of reasons which just confuse anyone trying to
get HTTPS cert validation done in the correct way.

If you want to know where requests is looking for the CA bundle you can run
`python -c "import requests.utils; print(requests.utils.DEFAULT_CA_BUNDLE_PATH)"`.

All is not lost and I've created this repo to try and navigate through the various distro specific options and paths to
create a detailed guide on how to get cert verification happening for WinRM in Ansible. There are a few levers you can
pull to configure cert validation but to specify an explicit path for the CA trust store then the following connection
specific variables are used:

* `winrm` -> `ansible_winrm_ca_trust_path`
* `psrp` -> `ansible_psrp_ca_cert`

Requests supports an absolute path to either a file of the CA chain or a directory that has been prepared with the
[c_rehash](https://www.openssl.org/docs/man1.0.2/man1/c_rehash.html) command from OpenSSL. When it comes to cert
validation of your own CA chain in ansible you have 5 options:

* Install requests from the system package manager like `dnf`, `yum`, `apt-get`. Typically this package is configured for each distro to use its system trust store
    * This is not a guarnatee and depends on how each distro packages it.
    * It is also not a good idea to mix system installed Python packages and pip installed Python packages which is complicated if the system does not provide all the Python packages you need
* Append your CA chain to the `certifi` package certs and let the defaults roll
    * This is **NOT** recommended as your certs will be removed once the package is upgraded (almost a certainty)
    * Also won't work if the installed requests package is explicitly configured to use the system trust store (see above)
* Specify the absolute path to your exported CA chain with the variable specific above
    * This works just fine and is distro agnostic, you just need to ensure you have the cert chain available on the Ansible controller
* Specify the absolute path to the distro specific cert bundle file
    * This is like the option above but now the CA chain is loaded into the system trust store allowing other applications to use it
    * An enterprise environment could also be including their issuring cert saving you a step
* Specify the absolute path to the distro specific cert directory
    * Like the above but you just specify the dir, requires the dir to be run with `c_rehash` but you can keep the cert separate from the main bundle if you wish

While the paths and commands that sync the certs differ per distro the basic workflow for the last 2 options are as
follows:

* Copy the certificate to a distro specific staging path
* Run a distro specific command to synchronize the certs with the system store - this will read all the certs in the staging path and place them in various locations on the host for all applications to use
* If you want to target a directory, run `c_rehash` to set up the system directory properly

Here is a breakdown of each distro and settings specific to it

| Distro | Staging Path | Sync Command | c_rehash Package | System Trust Dir | System Trust File Bundle |
| ------ | ------------ | -----------  | ---------------- | ---------------- | ------------------------ |
| Arch | /etc/ca-certificates/trust-source/anchors | update-ca-trust extract | openssl | /etc/ssl/certs | /etc/ssl/certs/ca-certificates.crt |
| Centos | /etc/pki/ca-trust/source/anchors | update-ca-trust extract | openssl-perl | /etc/pki/tls/certs | /etc/pki/tls/certs/ca-bundle.crt⁰ |
| Fedora | /etc/pki/ca-trust/source/anchors | update-ca-trust extract | openssl-perl | /etc/pki/tls/certs | /etc/pki/tls/certs/ca-bundle.crt |
| openSUSE Leap | /etc/pki/trust/anchors | update-ca-certificates | openssl | /etc/ssl/certs | /etc/ssl/ca-bundle.pem |
| Ubuntu | /usr/local/share/ca-certificates¹ | update-ca-certificates | openssl | /etc/ssl/certs² | /etc/ssl/certs/ca-certificates.crt |

`⁰` - The requests version installed by `yum install python-requests` on Centos 7 does not support dirs as a trust path. This is not a limitation when installed through pip or on Centos 8
`¹` - Copied file must have the extension `.crt` but can be a PEM encoded cert
`²` - The Python version included with Ubuntu 14.04 does not support dirs as a trust path


## Requirements

* Ansible
* Vagrant
* Docker


## Setup

To set up the Windows host and CA certificates run `vagrant up`.

To set up the test container for each distro run

* `docker build -f archlinux/Dockerfile .`
* `docker build -f centos7/Dockerfile .`
* `docker build -f centos8/Dockerfile .`
* `docker build -f fedora30/Dockerfile .`
* `docker build -f fedora31/Dockerfile .`
* `docker build -f opensuse15.2/Dockerfile .`
* `docker build -f ubuntu1404/Dockerfile .`
* `docker build -f ubuntu1604/Dockerfile .`
* `docker build -f ubuntu1804/Dockerfile .`

Each container is set up so that you have 2 Ansible installs to run from

* Ansible installed from the system package manager
    * Ubuntu 14.04 has a requests version that is too old for both pywinrm and pypsrp so this won't work there
* Ansible installed with pip to a virualenv at `ansible-venv/bin`

The inventory is also set up with 4 scenarios for the `winrm` and `psrp` connection plugin

* `<connection>`: No specified path, uses whatever the system is configured with - this should only work for a system package install
* `<connection>_file`: Absolute path to the CA chain that is not on the trusted store
* `<connection>_system_file`: Absolute path to the distro specific system trust store file
* `<connection>_system_dir`: Absolute path to the distro specific system trust store directory - this may not work for older versions of Python or requests

To test out these scenarios you can run the following:

```bash
# Run 'source ansible-venv/bin/activate' to test out the pip install scenario
ansible -i inventory.ini winrm -m win_ping
ansible -i inventory.ini winrm_file -m win_ping
ansible -i inventory.ini winrm_system_file -m win_ping
ansible -i inventory.ini winrm_system_dir -m win_ping

ansible -i inventory.ini psrp -m win_ping
ansible -i inventory.ini psrp_file -m win_ping
ansible -i inventory.ini psrp_system_file -m win_ping
ansible -i inventory.ini psrp_system_dir -m win_ping
```
