#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
source /opt/plexguide/functions/core.sh
source /opt/plexguide/functions/easy.sh

# install support
source /opt/plexguide/functions/install/aptupdate.sh
source /opt/plexguide/functions/install/docker.sh
source /opt/plexguide/functions/install/customcontainers.sh
source /opt/plexguide/functions/install/gcloud.sh
source /opt/plexguide/functions/install/emergency.sh
source /opt/plexguide/functions/install/hetzner.sh
source /opt/plexguide/functions/install/mergerfs.sh
source /opt/plexguide/functions/install/pgui.sh
source /opt/plexguide/functions/install/portainer.sh
source /opt/plexguide/functions/install/pythonstart.sh
source /opt/plexguide/functions/install/serverid.sh
source /opt/plexguide/functions/install/watchtower.sh


updateprime () {
# easy start var for easy installer
easy=off

# Changing the Numbers will Force a Certain Section to Rerun
abc="/var/plexguide"
mkdir -p ${abc}
chmod 0775 ${abc}
chown 1000:1000 ${abc}

# creates default folers and sets permissions
mkdir -p /var/plexguide
chmod 0775 /var/plexguide
chown 1000:1000 /var/plexguide

mkdir -p /opt/appdata/plexguide
chmod 0775 /opt/appdata/plexguide
chown 1000:1000 /opt/appdata/plexguide

core serverid
# default variables that get created; important to the project start
variable /var/plexguide/pgfork.project "UPDATE ME"
variable /var/plexguide/pgfork.version "changeme"
variable /var/plexguide/tld.program "portainer"
variable /opt/appdata/plexguide/plextoken ""
variable /var/plexguide/server.ht ""
variable /var/plexguide/server.email "NOT-SET"
variable /var/plexguide/server.domain "NOT-SET"
variable /var/plexguide/pg.number "New-Install"
variable /var/plexguide/emergency.log ""
variable /var/plexguide/pgbox.running ""
pgnumber=$(cat /var/plexguide/pg.number)

hostname -I | awk '{print $1}' > /var/plexguide/server.ip
file="${abc}/server.hd.path"
if [ ! -e "$file" ]; then echo "/mnt" > ${abc}/server.hd.path; fi

file="${abc}/new.install"
if [ ! -e "$file" ]; then newinstall; fi

ospgversion=$(cat /etc/*-release | grep Debian | grep 9)
if [ "$ospgversion" != "" ]; then echo "debian"> ${abc}/os.version;
else echo "ubuntu" > ${abc}/os.version; fi

# Set variable numbers, plus number up to force update
pgstore "install.merger" "1"
pgstore "install.python" "1"
pgstore "install.apt" "1"
pgstore "install.preinstall" "1"
pgstore "install.folders" "1"
pgstore "install.docker" "1"
pgstore "install.server" "1"
pgstore "install.serverid" "1"
pgstore "install.dependency" "1"
pgstore "install.dockerstart" "1"
pgstore "install.motd" "1"
pgstore "install.alias" "1"
pgstore "install.cleaner" "1"
pgstore "install.gcloud" "1"
pgstore "install.hetzner" "1"
pgstore "install.amazonaws" "1"
pgstore "install.watchtower" "1"
pgstore "install.installer" "1"
pgstore "install.prune" "1"
pgstore "install.mountcheck" "1"
}

pginstall () {
# Runs through the install process order
  updateprime
  bash /opt/plexguide/menu/pggce/gcechecker.sh
  core pythonstart
  core aptupdate
  core alias_install &>/dev/null &
  core folders
  core dependency
  core mergerinstall
  core dockerinstall
  core docstart

touch /var/plexguide/install.roles
rolenumber=3
  # Roles Ensure that PG Replicates and has once if missing; important for startup, cron and etc
if [[ $(cat /var/plexguide/install.roles) != "$rolenumber" ]]; then
  rm -rf /opt/communityapps
  rm -rf /opt/coreapps
  rm -rf /opt/pgshield

  pgcore
  pgcommunity
  pgshield
  echo "$rolenumber" > /var/plexguide/install.roles
fi

  portainer
  pgui
  core motd &>/dev/null &
  core hetzner &>/dev/null &
  core gcloud
  core cleaner &>/dev/null &
  core watchtower
  core prune
  customcontainers &>/dev/null &
  pgedition
  core mountcheck
  emergency
  pgdeploy
}

######################################################### Core INSTALLER
core () {
# This process is a function for the menu run down above
    touch /var/plexguide/install."${1}".stored
    start=$(cat /var/plexguide/install."${1}")
    stored=$(cat /var/plexguide/install."${1}".stored)
    if [ "$start" != "$stored" ]; then
      $1
      cat /var/plexguide/pg."${1}" > /var/plexguide/pg."${1}".stored;
    fi
}
######################################################### Core Installer Pieces

alias_install () { ansible-playbook /opt/plexguide/menu/alias/alias.yml }

cleaner () {
  ansible-playbook /opt/plexguide/menu/pg.yml --tags autodelete &>/dev/null &
  ansible-playbook /opt/plexguide/menu/pg.yml --tags clean &>/dev/null &
  ansible-playbook /opt/plexguide/menu/pg.yml --tags clean-encrypt &>/dev/null &
}

dependency () {
  ospgversion=$(cat /var/plexguide/os.version)
  if [ "$ospgversion" == "debian" ]; then
    ansible-playbook /opt/plexguide/menu/dependency/dependencydeb.yml;
  else
    ansible-playbook /opt/plexguide/menu/dependency/dependency.yml; fi
}

folders () { ansible-playbook /opt/plexguide/menu/installer/folders.yml }

motd () { ansible-playbook /opt/plexguide/menu/motd/motd.yml }

mountcheck () {
  bash /opt/plexguide/menu/pgcloner/solo/pgui.sh
  ansible-playbook /opt/pgui/pgui.yml
  ansible-playbook /opt/plexguide/menu/pgui/mcdeploy.yml

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
↘️  PG User Interface (PGUI) Installed / Updated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INFORMATION:  PGUI is a simple interface that provides information,
warnings, and stats that will assist both yourself and tech support!
To turn this off, goto settings and turn off/on the PG User Interface!

VISIT:
https://pgui.yourdomain.com | http://pgui.domain.com:8555 | ipv4:8555

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
read -p 'Acknowledge Info | Press [ENTER] ' typed < /dev/tty

}

newinstall () {
  rm -rf /var/plexguide/pg.exit 1>/dev/null 2>&1
  file="${abc}/new.install"
  if [ ! -e "$file" ]; then
    touch ${abc}/pg.number && echo off > /tmp/program_source
    bash /opt/plexguide/menu/version/file.sh
    file="${abc}/new.install"
    if [ ! -e "$file" ]; then exit; fi
 fi
}

# Roles Ensure that PG Replicates and has once if missing; important for startup, cron and etc
pgcore() { if [ ! -e "/opt/coreapps/place.holder" ]; then ansible-playbook /opt/plexguide/menu/pgbox/pgboxcore.yml; fi }
pgcommunity() { if [ ! -e "/opt/communityapps/place.holder" ]; then ansible-playbook /opt/plexguide/menu/pgbox/pgboxcommunity.yml; fi }
pgshield() { if [ ! -e "/opt/pgshield/place.holder" ]; then
echo 'pgshield' > /var/plexguide/pgcloner.rolename
echo 'PGShield' > /var/plexguide/pgcloner.roleproper
echo 'PGShield' > /var/plexguide/pgcloner.projectname
echo '87' > /var/plexguide/pgcloner.projectversion
echo 'pgshield.sh' > /var/plexguide/pgcloner.startlink
ansible-playbook "/opt/plexguide/menu/pgcloner/corev2/primary.yml"; fi }

pgdeploy () {
  touch /var/plexguide/pg.edition
  bash /opt/plexguide/menu/start/start.sh
}

pgedition () {
  file="${abc}/path.check"
  if [ ! -e "$file" ]; then touch ${abc}/path.check && bash /opt/plexguide/menu/dlpath/dlpath.sh; fi
  # FOR PG-BLITZ
  file="${abc}/project.deployed"
    if [ ! -e "$file" ]; then echo "no" > ${abc}/project.deployed; fi
  file="${abc}/project.keycount"
    if [ ! -e "$file" ]; then echo "0" > ${abc}/project.keycount; fi
  file="${abc}/server.id"
    if [ ! -e "$file" ]; then echo "[NOT-SET]" > ${abc}/rm -rf; fi
}

prune () { ansible-playbook /opt/plexguide/menu/prune/main.yml }
