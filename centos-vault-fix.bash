#!/bin/bash
# If downloading CentOS8 the default URL for the CentOS mirrorlist for patching has been deprecated as well as the OS at the time of this writing.
# In order to allow CentOS8 to retrieve rpm's from the internet, we'll need to change/fix the URL's in the repo files.

sed -i 's/mirror\.centos\.org/vault.centos.org/g' /etc/yum.repos.d/CentOS-*.repo
sed -i 's/^#.*baseurl=http/baseurl=http/g' /etc/yum.repos.d/CentOS-*.repo
sed -i 's/^mirrorlist=http/#mirrorlist=http/g' /etc/yum.repos.d/CentOS-*.repo
