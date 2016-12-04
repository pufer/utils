#!/bin/sh
 
# �����ִ����lnmp_for_el7.sh����ʹ�ñ��ű����ǰ�װnginx����ò�Ҫֱ��ʹ�ñ��ű���ֱ��ʹ�õĻ���û�в��ԣ�
# CentOS 7Ĭ��ʹ��openssl 1.0.1����������汾��֧��ALPN, ����� http://nginx.org/en/docs/http/ngx_http_v2_module.html#issues
# ����nginx 1.10.0�Ժ�ֻ��HTTP/2ģ�飬������spdy�����ҳ�chrome��������������֧��ALPN���ܿ���HTTP/2
# ���ű�������CentOS 7�ϱ���openssl 1.0.2�������±���nginx����openssl���������ú͹ٷ��汾һ����
# ����ѡ��ο��� http://nginx.org/en/linux_packages.html#arguments

WORKING_DIR="$PWD";
OPENSSL_PREFIX_DIR=/usr/local/openssl-1.0.2;
OPENSSL_VERSION=1.0.2j;
NGINX_VERSION=1.10.2;

OPENSSL_DIR_NAME="openssl-$OPENSSL_VERSION";
OPENSSL_PKG_NAME="$OPENSSL_DIR_NAME.tar.gz";
NGINX_DIR_NAME="nginx-$NGINX_VERSION";
NGINX_PKG_NAME="$NGINX_DIR_NAME.tar.gz";


# ���Դ
yum install epel-release;
rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm ;

# ��װ������
yum install -y yum-utils yum-plugin-remove-with-leaves yum-cron yum-plugin-upgrade-helper yum-plugin-fastestmirror rpm-build;
yum install -y nginx
yum-builddep -y nginx;

# ����openssl
if [ ! -e "$OPENSSL_PKG_NAME" ]; then
    wget "https://www.openssl.org/source/$OPENSSL_PKG_NAME";
fi

tar -axvf "$OPENSSL_PKG_NAME";
if [ ! -e "$OPENSSL_PREFIX_DIR" ]; then
    cd "$OPENSSL_DIR_NAME";
    ./config --prefix="$OPENSSL_PREFIX_DIR";
    make;
    make install;
    cd - ;
fi

# build nginx
if [ ! -e "$NGINX_PKG_NAME" ]; then
    wget "http://nginx.org/download/$NGINX_PKG_NAME";
fi

tar -axvf "$NGINX_PKG_NAME";
cd "$NGINX_DIR_NAME";

# ����ѡ��ο��� http://nginx.org/en/linux_packages.html#arguments

./configure \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-threads \
--with-stream \
--with-stream_ssl_module \
--with-http_slice_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-http_v2_module \
--with-ipv6 \
--with-openssl="$WORKING_DIR/$OPENSSL_DIR_NAME" \
--with-openssl-opt="-fPIC" ;

make;
make install;