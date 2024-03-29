#!/bin/sh

# Workaround to get initial configuration from
# archived dir centreon.initial (created during docker build)
if [ ! -f "/etc/centreon/.done" ]; then
  cp -a /etc/centreon.initial/* /etc/centreon/
  touch "/etc/centreon/.done"
fi

# Workaround centreon stuck into infinite install wizard loop
# /!\ After firstrun wizard, RESTART docker so that code gets
# executed
if [ -f "/etc/centreon/conf.pm" -a "${1}" != "upgrade" ]; then
  rm -rf /srv/centreon/www/install/
fi

# Workaround gorgone migration missing a file
# https://github.com/centreon/centreon-gorgone/issues/168
if [ ! -d /etc/centreon-gorgone ]; then
    mkdir /etc/centreon-gorgone
fi
if [ ! -d /etc/centreon-gorgone/config.d ]; then
    mkdir /etc/centreon-gorgone/config.d
fi
if [ ! -f /etc/centreon-gorgone/config.d/30-centreon.yaml ]; then
    echo 'name: centreon.yaml' > /etc/centreon-gorgone/config.d/30-centreon.yaml
    echo 'description: Configure Centreon Gorgone to work with Centreon Web.' >> /etc/centreon-gorgone/config.d/30-centreon.yaml
    echo 'centreon: !include /etc/centreon/config.d/*.yaml' >> /etc/centreon-gorgone/config.d/30-centreon.yaml
fi

# Fix perms (do it all the time because centreon uid may change)
chown -R www-data:centreon /etc/centreon
chmod 750 /etc/centreon

# Init folder for the first time
find /var/log/centreon-engine/      -maxdepth 0 -empty -exec rsync -avz /var/log/centreon-engine.initial/ /var/log/centreon-engine/ \;
find /var/lib/centreon-engine/      -maxdepth 0 -empty -exec rsync -avz /var/lib/centreon-engine.initial/ /var/lib/centreon-engine/ \;
find /var/log/centreon-broker/      -maxdepth 0 -empty -exec rsync -avz /var/log/centreon-broker.initial/ /var/log/centreon-broker/ \;
find /var/lib/centreon-broker/      -maxdepth 0 -empty -exec rsync -avz /var/lib/centreon-broker.initial/ /var/lib/centreon-broker/ \;
find /var/log/centreon-gorgone/     -maxdepth 0 -empty -exec rsync -avz /var/log/centreon-gorgone.initial/ /var/log/centreon-gorgone/ \;
find /var/lib/centreon-gorgone/     -maxdepth 0 -empty -exec rsync -avz /var/lib/centreon-gorgone.initial/ /var/lib/centreon-gorgone/ \;
find /var/lib/centreon/             -maxdepth 0 -empty -exec rsync -avz /var/lib/centreon.initial/        /var/lib/centreon/        \;
find /var/cache/nagvis/userfiles/   -maxdepth 0 -empty -exec rsync -avz /var/cache/nagvis/userfiles.initial/      /var/cache/nagvis/userfiles/ \;
find /etc/centreon-broker/          -maxdepth 0 -empty -exec rsync -avz /etc/centreon-broker.initial/ /etc/centreon-broker/ \;
find /etc/centreon-engine/          -maxdepth 0 -empty -exec rsync -avz /etc/centreon-engine.initial/ /etc/centreon-engine/ \;
find /etc/centreon-gorgone/         -maxdepth 0 -empty -exec rsync -avz /etc/centreon-gorgone.initial/ /etc/centreon-gorgone/ \;

# Bad permissions can occurs as the volume is on the host
# systemd uid of centreon-broker and centreon-engine
# may change when regenerating container
chown -R centreon-broker:centreon-broker /etc/centreon-broker/ /var/log/centreon-broker/ /var/lib/centreon-broker/
chown -R centreon-engine:centreon-engine /etc/centreon-engine/ /var/log/centreon-engine/ /var/lib/centreon-engine/
chown -R centreon:centreon-broker /var/lib/centreon/metrics/ /var/lib/centreon/status/
chown -R centreon-gorgone:centreon-gorgone /etc/centreon-gorgone/ /var/log/centreon-gorgone/ /var/lib/centreon-gorgone/
if [ -d /var/lib/centreon/centplugins ]; then
    chown -R centreon:centreon /var/lib/centreon/centplugins
fi
find /var/lib/centreon/metrics/ -type f -exec chmod 0664 {} \;
find /var/lib/centreon/status/ -type f -exec chmod 0664 {} \;
find /var/log/centreon-broker/ -type f -exec chmod 0664 {} \;
find /var/log/centreon-engine/ -type f -exec chmod 0664 {} \;

# Since 18.10 PHP session from PHP-FPM are here
rm -rf /var/lib/centreon/sessions
mkdir -p /var/lib/centreon/sessions
chown root:www-data /var/lib/centreon/sessions
chmod 0770 /var/lib/centreon/sessions

# Since 19.04, When ACKing a service it Centreon-Web attemps to create a file here
mkdir -p /var/lib/centreon/centcore
chown -R root:www-data /var/lib/centreon/centcore
chmod 0770 /var/lib/centreon/centcore

# This folder has been added with 20.04 and upgrade from previous version create DB access YAML config in it
mkdir -p /etc/centreon/config.d
chown -R www-data:centreon /etc/centreon/config.d
chmod 0755 /etc/centreon/config.d

# Init like system to start services
supervisord -n -c /etc/supervisor/supervisord.conf -e debug
