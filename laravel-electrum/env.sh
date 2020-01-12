#!/bin/bash

APP_KEY=`grep APP_KEY=base64 .env | sed s/APP_KEY=//`

echo $APP_KEY

sed "s|'APP_KEY'|'APP_KEY','$APP_KEY'|" < config/app.php | sed "s|'UTC'|'UTC'|" > config/app.php.new
diff config/app.php config/app.php.new
mv config/app.php.new config/app.php


ARCH=
dpkgArch="$(dpkg --print-architecture)"
case "${dpkgArch##*-}" in
    amd64) ARCH='x86_64';;
    ppc64el) ARCH='ppc64le';;
    s390x) ARCH='s390x';;
    arm64) ARCH='arm64';;
    armhf) ARCH='armv7l';;
    i386) ARCH='x86';;
    *) echo "unsupported architecture"; exit 1 ;;
esac
if [ "${ARCH}" = "s390x" ]; then
    TITLE="Secure Bitcoin Wallet on IBM LinuxONE"
else
    TITLE="Bitcoin Wallet on "${ARCH}" Linux"
fi
echo $TITLE

cp .env .env.orig
sed --in-place s/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/ .env
sed --in-place s/DB_HOST=127.0.0.1/\#DB_HOST=127.0.0.1/ .env
sed --in-place s/DB_PORT=3306/\#DB_PORT=3306/ .env
sed --in-place "s|DB_DATABASE=homestead|DB_DATABASE=$APP_ROOT/database/development.sqlite3|" .env
sed --in-place s/DB_USERNAME=homestead/\#DB_USERNAME=homestead/ .env
sed --in-place s/DB_PASSWORD=secret/\#DB_PASSWORD=secret/ .env
sed --in-place "s|APP_NAME=Laravel|APP_NAME=\"${TITLE}\"|" .env

diff .env .env.orig

# sed s/right/left/  < resources/views/layouts/app.blade.php > resources/views/layouts/app.blade.php.new
# diff resources/views/layouts/app.blade.php resources/views/layouts/app.blade.php.new
# mv resources/views/layouts/app.blade.php.new resources/views/layouts/app.blade.php

touch $APP_ROOT/database/development.sqlite3
