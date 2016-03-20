FROM flem/php5-fpm:latest
MAINTAINER Franck Lemoine <franck.lemoine@flem.fr>

# properly setup debian sources
ENV DEBIAN_FRONTEND=noninteractive

ENV PHP_INI_DIR=/usr/local/etc/php/conf.d
ENV DOKUWIKI_VERSION 2015-08-10a
ENV DOKUWIKI_CHEKSUM a4b8ae00ce94e42d4ef52dd8f4ad30fe
ENV DOKUWIKI_PREFIX /opt/www/dokuwiki

# Update & install packages & cleanup afterwards
RUN buildDeps=' \
		wget \
	' \
	&& set -x \
	&& apt-get update \
	&& apt-get -y upgrade \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& wget -q -O /dokuwiki.tgz "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" \
	&& if [ "$DOKUWIKI_CHEKSUM" != "$(md5sum /dokuwiki.tgz | awk '{print($1)}')" ];then echo "Wrong md5sum of downloaded file!"; exit 1; fi \
	&& mkdir -p $DOKUWIKI_PREFIX \
	&& tar -xzf /dokuwiki.tgz -C $DOKUWIKI_PREFIX --strip-components 1 \
	&& mkdir -p $DOKUWIKI_PREFIX/conf/tpl/dokuwiki \
	&& chown -R www-data:www-data $DOKUWIKI_PREFIX \
	&& rm /dokuwiki.tgz \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*

COPY htaccess $DOKUWIKI_PREFIX/.htaccess
COPY style.ini $DOKUWIKI_PREFIX/conf/tpl/dokuwiki/style.ini
RUN chown www-data:www-data $DOKUWIKI_PREFIX/.htaccess \
	&& chown www-data:www-data $DOKUWIKI_PREFIX/conf/tpl/dokuwiki/style.ini

COPY doku-php.ini $PHP_INI_DIR

VOLUME ["/opt/www"]

