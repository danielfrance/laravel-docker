FROM php:8.3-apache

USER root

WORKDIR /var/www/html

# Add docker php ext repo
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install php extensions
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions mbstring pdo_mysql zip exif pcntl gd memcached

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    zip \
    curl \
    git \
    unzip \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_pgsql pgsql zip gd mbstring \
    && a2enmod rewrite


# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install pnpm for TypeScript builds
RUN npm install -g pnpm


COPY . .

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Ensure required directories exist
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache


# Set permissions

RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# this file needs to be executable on your host machine first.
RUN chmod +x /var/www/html/run.sh 


EXPOSE 80

# Enable Laravel configuration
RUN printf '<Directory /var/www/html>\n    AllowOverride All\n    Require all granted\n</Directory>\n' > /etc/apache2/conf-available/laravel.conf \
    && a2enconf laravel

# Set DocumentRoot to public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf


ENTRYPOINT ["/var/www/html/run.sh"]
