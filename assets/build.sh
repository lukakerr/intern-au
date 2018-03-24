#!/bin/sh

echo "Building assets"

mkdir -p ../public/css
mkdir -p ../public/js

# sass
touch ../public/css/main.css
sass --sourcemap=none sass/main.sass ../public/css/main.css

# coffeescript
find coffee/ -type f -name "*.coffee" | xargs -I{} sh -c "cat {}; echo ''" > main.coffee
coffee -c main.coffee
cp main.js ../public/js
rm main.coffee
rm main.js

# js
find js/ -name "*.js" -exec cat {} \; > vendor.js
cp vendor.js ../public/js
rm vendor.js

# static
cp -rf static/. ../public