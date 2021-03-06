#!/bin/bash

cd `dirname $0`; cd ..
SRC_DIR=`pwd`

[[ "$1" = "" ]] && echo "Usage : $0 [config]" && exit 1

CONFIG_NAME=$1

CONF_BASE=/opt/openresty/nginx

cd $CONF_BASE

if [[ -d conf && ! -L conf ]]; then
    sudo mv -f conf conf.DEFAULT
fi

echo "OpenResty config : $CONF_BASE/conf => $SRC_DIR/conf/nginx/$CONFIG_NAME"

sudo ln -sfT $SRC_DIR/conf/nginx/$CONFIG_NAME conf
sudo /etc/init.d/openresty restart
