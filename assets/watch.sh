#!/bin/sh

echo "Watching sass and coffeescript"
echo "Make changes and reload your browser"

# Run both sass and coffee watch
# Kill sass (in background) when script exited
# Coffee (in foreground) is killed when script exited
trap 'kill %1; exit' SIGINT
sass --watch --sourcemap=none sass/main.sass:../public/css/main.css & coffee -wcj ../public/js/main.js coffee/