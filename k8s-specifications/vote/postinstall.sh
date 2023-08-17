#!/bin/sh
# Wait for index.html file
while [ ! -f "/app/templates/index.html" ]; do
    echo "Waiting for index.html file to be ready..."
    sleep 2
done
echo "File exists, proceeding..."
echo 'Updating template'
sed -i 's/vs/or/g' /app/templates/index.html
echo 'Done updating template'
# Wait until curl succeeds
until curl -Is http://vote:5000 | head -1 | grep -q "HTTP/1.1 200"; do
    echo "Waiting for response... from vote app"
    sleep 5
done
echo "Received successful response!"