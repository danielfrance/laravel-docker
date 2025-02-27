#!/bin/sh

echo "🚀 Setting up Laravel Application"
echo "📦 Running Composer Install"
composer install --no-interaction --prefer-dist --optimize-autoloader

echo "Application environment: $APP_ENV"
#  if the value of APP_KEY is empty, generate a new one
# if [ -z "$APP_KEY" ]; then
#     echo "🔑 Generating APP_KEY"
#     php artisan key:generate
# fi


echo "🔥 Clearing Cache/Views/Configs"
php artisan view:clear
php artisan config:clear
php artisan cache:clear

echo "🚀 Running migrations"
php artisan migrate

echo "🚀 starting frontend build"
echo "installing dependencies"
npm install
echo "building frontend"
npm run build

echo "🚀 Starting Apache"
apache2-foreground