FROM node:20.19.1

RUN apt-get update -y

RUN apt-get install -y apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN apt-get update && \
    apt-get install -y \
        php8.2 \
        php8.2-bcmath \
        php8.2-gd \
        php8.2-intl \
        php8.2-mbstring \
        php8.2-opcache \
        php8.2-pdo \
        php8.2-soap \
        php8.2-xsl \
        php8.2-zip \
        php8.2-pdo-mysql \
        php8.2-yaml \
    && apt-get clean

# Composer
COPY --from=composer:2.2.14 /usr/bin/composer /usr/local/bin/composer

RUN mkdir -p /home/app \
    && usermod -d /home/app -l app node \
    && chown -R app /home/app

USER app

WORKDIR /var/www/html

