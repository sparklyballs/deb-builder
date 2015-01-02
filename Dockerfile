# set base os
FROM phusion/baseimage:0.9.15
ENV DEBIAN_FRONTEND noninteractive
# Set correct environment variables
ENV HOME /root
# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh && \
mkdir -p /root/debout /root/patches

VOLUME /root/debout
VOLUME /root/patches

ADD patches /root/patches/

# Install checkinstall 

RUN apt-get update && \

apt-get install build-essential automake autoconf libtool pkg-config libcurl4-openssl-dev intltool libxml2-dev libgtk2.0-dev libnotify-dev libglib2.0-dev libevent-dev checkinstall software-properties-common python-software-properties git curl wget -y

# Install KODI build dependencies
RUN add-apt-repository -s ppa:team-xbmc/ppa
RUN apt-get update && \

apt-get build-dep kodi -y
# Pull kodi source from git and apply any patches
# Edit this section for branch, configure enables/disables  and patch etc.....


# Main git source
RUN git clone https://github.com/topfs2/xbmc.git

# mv patch to xbmc folder

RUN cd xbmc && \
# mv /root/patches/5071.patch . && \

# checkout branch/tag

git checkout helix_headless && \

# Apply patch(s)

# git apply 5071.patch && \

# Configure, make, clean.
./bootstrap && \
./configure \
--prefix=/opt/kodi-server && \
make

RUN cd xbmc && \
checkinstall -y --fstrans=no --install=yes --pkgname=sparkly-kodi-headless --pkgversion="`date +%Y%m%d`.`git rev-parse --short HEAD`"

ADD startup/movedeb.sh /root/movedeb.sh
RUN chmod +x /root/movedeb.sh

ENTRYPOINT ["/root/movedeb.sh"]
