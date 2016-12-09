# cliff-installation-script
Script to install CLIFF on a Linux machine

Used on an Ubuntu 16.04 server VM built on Azure.  Based heavily on the CLIFF Vagrant installation script [citation needed].

## Usage
$ sudo ./install_cliff.sh

## Notes
Make sure your VM has at least 4GB RAM as I ran into problems with less than that on the allNames index building.  CLIFF itself seems to be able to run with 3.5GB.

### Run script automatically on startup
See file `tomcatCliff`

```
$ sudo vi /etc/init.d/tomcatCliff
$ sudo chmod 755 /etc/init.d/tomcatCliff
$ sudo update-rc.d tomcatCliff defaults
```
