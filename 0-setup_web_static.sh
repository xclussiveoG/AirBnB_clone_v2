#!/usr/bin/env bash
# This script configures web servers for deployment

if [[ $EUID -ne 0 ]]; then
    echo "You need to be root run this script."
    exit 1
fi

# install nginx if it doesn't exist
command -v nginx > /dev/null
if [[ $? -eq 1 ]]; then
    apt install nginx -y
fi

# create needed directories
mkdir -p /data/web_static/shared 2> /dev/null
mkdir -p /data/web_static/releases/test 2> /dev/null

# a dummy HTML to check it works
echo "
<html lang='en'>
    <head>
        <title>Airbnb Clone</title>
        <style>
        .container {
            margin: 0 auto;
        }

        .text {
            font-size: 2em;
            text-align: center;
        }

        hr {
            border: 2px solid black;
        }
        </style>
    </head>
    <body>
        <div class='container'>
            <h1 class='text'>Yep, it works. I am $HOSTNAME</h1>
            <hr>
        </div>
    </body>
</html>
" > /data/web_static/releases/test/index.html

# create link for current release
ln -sf /data/web_static/releases/test /data/web_static/current

# allow user to have permissions over directories
chown -R ubuntu:ubuntu /data

# update nginx configuration to add alias configuration
grep -q "location /hbnb_static {" /etc/nginx/sites-available/default
if [[ $? -eq 1 ]]; then
    sed -i "/server_name _;/a \\\n\tlocation /hbnb_static {\n\t\talias /data/web_static/current/;\n\t}" /etc/nginx/sites-available/default
fi

# restart nginx
service nginx restart
