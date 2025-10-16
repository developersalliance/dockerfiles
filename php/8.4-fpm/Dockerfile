FROM php:8.4-fpm-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
  cron \
  git \
  gzip \
  libfreetype6-dev \
  libicu-dev \
  libzip-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libxslt1-dev \
  libonig-dev \
  libmagickwand-dev \
  lsof \
  mariadb-client \
  vim \
  zip \
  openssh-client \
  openssh-server \
  procps \
  rsync \
  sudo \
  golang-go \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-configure pcntl --enable-pcntl

RUN docker-php-ext-install \
  bcmath \
  gd \
  intl \
  opcache \
  pcntl \
  pdo_mysql \
  soap \
  xsl \
  zip \
  sockets \
  pcntl \
  ftp

RUN mkdir /opt/go \
    && export GOPATH=/opt/go \
    && go install github.com/mailhog/mhsendmail@v0.2.0

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
  && pecl install xdebug-3.4.3 \
  && docker-php-ext-enable xdebug \
  && sed -i -e 's/^zend_extension/\;zend_extension/g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install imagick
RUN curl -L -o /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/refs/tags/3.7.0.tar.gz \
    && mkdir -p /tmp/imagick \
    && tar --directory /tmp/imagick --strip-components=1 -xf /tmp/imagick.tar.gz \
    && cd /tmp/imagick \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && cd / \
    && rm -rf /tmp/imagick && rm /tmp/imagick.tar.gz \
    && docker-php-ext-enable imagick

# Clean up apt-get update
RUN rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2.8.12 /usr/bin/composer /usr/local/bin/composer

# Install Magerun2 from n98
RUN curl -O https://files.magerun.net/n98-magerun2.phar; \
    chmod +x ./n98-magerun2.phar; \
    mv ./n98-magerun2.phar /usr/local/bin/n98-magerun2

# php-spx
RUN git clone https://github.com/NoiseByNorthwest/php-spx.git \
    && cd php-spx \
    && git checkout release/latest \
    && phpize \
    && ./configure \
    && make \
    && make install

RUN groupadd -g 1000 app \
 && useradd -g 1000 -u 1000 -d /var/www -s /bin/bash app

COPY conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/php.ini /usr/local/etc/php/
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/
COPY conf/php-fpm.conf /usr/local/etc/
COPY conf/spx.ini /usr/local/etc/php/conf.d/

RUN mkdir /sock
RUN chown -R app:app /usr/local/etc/php/conf.d /sock

RUN mkdir -p /var/www && chown -R app:app /var/www/
RUN echo "app ALL=(ALL) NOPASSWD: /bin/chown,/usr/sbin/sshd" >> /etc/sudoers.d/app

RUN mkdir /run/sshd
RUN echo 'app:password' | chpasswd

USER app:app

VOLUME /var/www

WORKDIR /var/www/html

EXPOSE 9000

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "php-fpm" ]
