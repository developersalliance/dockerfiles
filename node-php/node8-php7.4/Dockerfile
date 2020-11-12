FROM node:8

RUN apt-get update -y
RUN npm install -g grunt-cli && npm install -g bower
RUN npm install --save gulp-install && npm install gulp-sass && npm install -g gulp

RUN apt-get install -y apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN apt-get update && \
    apt-get install -y \
        php7.4 \
        php7.4-bcmath \
        php7.4-gd \
        php7.4-intl \
        php7.4-mbstring \
        php7.4-opcache \
        php7.4-pdo \
        php7.4-soap \
        php7.4-xsl \
        php7.4-zip \
        php7.4-pdo-mysql \
    && apt-get clean

RUN mkdir -p /home/app \
    && usermod -d /home/app -l app node \
    && chown -R app /home/app

USER app

WORKDIR /var/www/html
