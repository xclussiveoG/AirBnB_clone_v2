# This manifest configures an nginx web server with an alias

$html="
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
            <h1 class='text'>Yep, it works. I am ${::facts['networking']['hostname']}</h1>
            <hr>
        </div>
    </body>
</html>
"

$alias_config="
    location /hbnb_static {
        alias /data/web_static/current/;
    }
"

exec { 'update packages list':
  command => '/usr/bin/apt-get update -y',
  path    => '/usr/bin:/usr/sbin:/bin',
}

package { 'nginx':
  ensure => installed,
  require => Exec['update packages list'],
}

file { ['/data/',
        '/data/web_static/',
        '/data/web_static/shared/',
        '/data/web_static/releases',
        '/data/web_static/releases/test',]:
    ensure  => 'directory',
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0755',
    require => Package['nginx'],
    recurse => true,
}

file { '/data/web_static/releases/test/index.html':
    ensure  => 'present',
    content => $html,
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0644',
    require => File['/data/web_static/releases/test'],
}

file { '/data/web_static/current':
    ensure  => 'link',
    target  => '/data/web_static/releases/test',
    require => File['/data/web_static/releases/test/index.html'],
    owner   => 'ubuntu',
    group   => 'ubuntu',
}

exec { 'update_nginx_config':
  command => "sed -i '/server_name _;/a ${alias_config}' /etc/nginx/sites-available/default",
  unless  => 'grep -q "location /hbnb_static {" /etc/nginx/sites-available/default',
  require => File['/data/web_static/current'],
  path    => '/usr/bin:/usr/sbin:/bin',
}

service { 'nginx':
    ensure    => 'running',
    enable    => 'true',
    subscribe => Exec['update_nginx_config'],
}
