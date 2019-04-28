#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
hetzner () {
  if [ -e "$file" ]; then rm -rf /bin/hcloud; fi
  version="v1.10.0"
  wget -P /pg/tmp "https://github.com/hetznercloud/cli/releases/download/$version/hcloud-linux-amd64-$version.tar.gz"
  tar -xvf "/pg/tmp/hcloud-linux-amd64-$version.tar.gz" -C /pg/tmp
  mv "/pg/tmp/hcloud-linux-amd64-$version/bin/hcloud" /bin/
  rm -rf /pg/tmp/hcloud-linux-amd64-$version.tar.gz
  rm -rf /pg/tmp/hcloud-linux-amd64-$version
}
