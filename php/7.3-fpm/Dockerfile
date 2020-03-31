FROM php:7.3-fpm
MAINTAINER Juan Alonso <juan.jalogut@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
  cron \
  git \
  gzip \
  libfreetype6-dev \
  libicu-dev \
  libzip-dev \
#  libgmp-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng-dev \
  libxslt1-dev \
  lsof \
  mariadb-client \
  vim \
  zip \
  procps \
  openssh-client \
  sudo \
  golang-go \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure \
  gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
  bcmath \
  gd \
  intl \
  mbstring \
  opcache \
  pcntl \
  pdo_mysql \
  soap \
  xsl \
#  gmp \
  zip \
  sockets

RUN mkdir /opt/go \
    && export GOPATH=/opt/go \
    && go get github.com/mailhog/mhsendmail

# Remove libsodium and install upgrading version:
RUN rm -f /usr/local/etc/php/conf.d/*sodium.ini \
  && rm -f /usr/local/lib/php/extensions/*/*sodium.so \
  && apt-get remove libsodium* -y  \
  && mkdir -p /tmp/libsodium  \
  && curl -sL https://github.com/jedisct1/libsodium/archive/1.0.18-RELEASE.tar.gz | tar xzf - -C  /tmp/libsodium \
  && cd /tmp/libsodium/libsodium-1.0.18-RELEASE/ \
  && ./configure \
  && make && make check \
  && make install  \
  && cd / \
  && rm -rf /tmp/libsodium  \
  && pecl install -o -f libsodium

RUN docker-php-ext-enable sodium

RUN pecl channel-update pecl.php.net \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug \
  && sed -i -e 's/^zend_extension/\;zend_extension/g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Clean up apt-get update
RUN rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | \
  php -- --install-dir=/usr/local/bin --filename=composer

# ioncube loader
RUN curl -fSL 'https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz' -o ioncube.tar.gz \
  && mkdir -p /tmp/ioncube \
  && tar -xvvzf ioncube.tar.gz \
  && mv ioncube/ioncube_loader_lin_7.3.so `php-config --extension-dir` \
  && rm -Rf ioncube.tar.gz ioncube \
  && docker-php-ext-enable ioncube_loader_lin_7.3

# Install MQ packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends alien \
    && curl -fsSL 'https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev90_linux_x86-64.tar.gz' -o mqc.tar.gz \
    && mkdir -p mqc \
    && tar -xf mqc.tar.gz -C mqc --strip-components=1\
    && rm mqc.tar.gz \
    && ( \
        cd mqc \
        && sed -i 's/^UNAME_FLAG=-i/UNAME_FLAG=-m/' ./mqlicense.sh \
        && ./mqlicense.sh -accept \
        && alien --scripts --to-deb MQSeriesRuntime-9.0.0-0.x86_64.rpm \
        && dpkg -i mqseriesruntime_9.0.0-1_amd64.deb \
        && alien --scripts --to-deb MQSeriesClient-9.0.0-0.x86_64.rpm \
        && dpkg -i mqseriesclient_9.0.0-1_amd64.deb \
        && alien --scripts --to-deb MQSeriesSDK-9.0.0-0.x86_64.rpm \
        && dpkg -i mqseriessdk_9.0.0-1_amd64.deb \
        && alien --scripts --to-deb MQSeriesSamples-9.0.0-0.x86_64.rpm \
        && dpkg -i mqseriessamples_9.0.0-1_amd64.deb \
    ) \
    && rm -r mqc

# Install mqseries
RUN curl -fsSL 'https://github.com/rstmpw/pecl-networking-mqseries/archive/php7-mqmh.tar.gz' -o mqseries.tar.gz \
    && mkdir -p mqseries \
    && tar -xf mqseries.tar.gz -C mqseries --strip-components=1 \
    && rm mqseries.tar.gz \
    && ( \
        cd mqseries \
        && phpize \
        && ./configure CFLAGS="-O2 -g" --with-libdir=lib64 \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r mqseries \
    && docker-php-ext-enable mqseries \
    && apt-get purge --auto-remove -y alien \
    && apt-get autoclean -qy && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 app \
 && useradd -g 1000 -u 1000 -d /var/www -s /bin/bash app

COPY conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/php.ini /usr/local/etc/php/
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/
COPY conf/php-fpm.conf /usr/local/etc/

RUN mkdir /sock
RUN chown -R app:app /usr/local/etc/php/conf.d /sock

RUN mkdir -p /var/www && chown -R app:app /var/www/
RUN echo "app ALL=(ALL) NOPASSWD: /bin/chown" >> /etc/sudoers.d/app

USER app:app

VOLUME /var/www

WORKDIR /var/www/html

EXPOSE 9000

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "php-fpm" ]
