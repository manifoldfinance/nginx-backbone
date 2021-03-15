#!/bin/bash
set -euo pipefail

mkdir -p /opt/src \
  && curl -L http://nginx.org/download/nginx-1.18.0.tar.gz 2> /dev/null > /opt/src/nginx-1.18.0.tar.gz \
  && curl -L https://github.com/vision5/ngx_devel_kit/archive/v0.3.1.tar.gz 2> /dev/null > /opt/src/ngx_devel_kit-0.3.1.tar.gz \
  && curl -L https://github.com/openresty/lua-nginx-module/archive/v0.10.7.tar.gz 2> /dev/null > /opt/src/lua-nginx-module-0.10.19.tar.gz \
  && curl -L https://github.com/openresty/lua-cjson/archive/2.1.0.8rc1.tar.gz 2> /dev/null > /opt/src/lua-cjson-2.1.0.8rc1.tar.gz

cd /opt/src && tar xfz lua-cjson-2.1.0.8rc1.tar.gz && cd lua-cjson-2.1.0.8rc1 \
  && sed -i.bak 's/LUA_INCLUDE_DIR =.*/LUA_INCLUDE_DIR = \/usr\/include\/luajit-2.0/g' Makefile \
  && sed -i.bak 's/LUA_MODULE_DIR =.*/LUA_MODULE_DIR = \/usr\/share\/luajit-2.0.3\/jitg/g' Makefile \
  && make && make install

cd /opt/src && tar xfz nginx-1.18.0.tar.gz && tar xfz ngx_devel_kit-0.3.1.tar.gz && tar xfz lua-nginx-module-0.10.19.tar.gz

cd /opt/src/nginx-1.18.0 && ./configure --prefix=/opt/nginx --with-ld-opt="-Wl,-rpath,/usr/local/lib" --add-module=/opt/src/ngx_devel_kit-0.3.1 --add-module=/opt/src/lua-nginx-module-0.10.19 --with-http_ssl_module \
  && make && make install \
  && rm /opt/src/*.tar.gz

cp nginx.conf /etc/nginx.conf
cp eth-jsonrpc-access.lua /opt/nginx/eth-jsonrpc-access.lua
cp nginx.logrotate /etc/logrotate.d/nginx
cp nginx-ssl.crt /etc/ssl/certs/nginx-ssl.crt
cp nginx-ssl.key /etc/ssl/private/nginx-ssl.key

# forward request and error logs to docker log collector
ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
