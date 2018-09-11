# Get started with docker-centreon
```bash
cd /tmp
git clone https://github.com/EarthLab-Luxembourg/docker-centreon.git
cd docker-centreon
git submodule update --init --recursive
```

# Before building your own image

Edit `CONFIG` file and set your local settings before doing anything.
Also download VMware-vSphere-Perl-SDK-6.5.0-4566394.x86\_64.tar.gz from VMWare (for ESX monitoring) into buildenv/files/other/vmware/ folder.

# Building the image
```bash
cd /tmp/docker-centreon
./build.sh
```

# Running the image
```bash
cd /tmp/docker-centreon
./run.sh
```

# MySQL/MariaDB on the host
An external MariaDB container may be needed.
```bash
sudo docker run -itd \
    -e MYSQL_ROOT_PASSWORD=secret \
    --name centreon-db \
    mariadb
```

There's no point trying to fight with Centreon Web installer.
The only way to get thru is to temporary create a network-enabled superadmin user and let him do what he wants:
```
CREATE USER 'root'@'%' IDENTIFIED BY 'secret';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

Once the installation finished you can edit centreon user to relax host checking (because docker IP may change) and purge the superadmin:
```
DROP USER 'root'@'%';
USE mysql;
UPDATE user SET Host='172.17.%' WHERE User='centreon';
GRANT ALL PRIVILEGES ON centreon.* TO 'centreon'@'172.17.%';
GRANT ALL PRIVILEGES ON centreon_storage.* TO 'centreon'@'172.17.%';
FLUSH PRIVILEGES;
```

# After installation wizard

For some unknown reason Centreon gets stuck into an infinite wizard loop. Just restart the container.
Centreon is now available on http://docker.host:8080/centreon/.

# mklive-status TCP socket

mklive-status socket will be exported over TCP so you can easily use Nagvis or Truk on the host itself, or another machine/container.
Everything is ready and mklive will be exported on TCP/6557 on the host.

However, you need to configure Centreon Engine to output using mklive.
For this, log into the Web interface en go to: Configuration > Pollers > Engine configuration (left) and click on "Centreon Engine CFG 1".
Then, go to the "Data" tab and add a new "Broker module" with the following content: `/usr/lib/check_mk/livestatus.o /var/lib/centreon-engine/rw/live`
To apply this new configuration, generate it and tick **restart**. Reloading is not sufficient when adding a module.

On the host, test it using `echo -e "GET hosts\n" | netcat 127.0.0.1 6557`

# TODO

* Provide a proper package for nagios-plugins-bigdata
* Make Dockerfile modular using Python script and Jinja2 templates
* Import packages.le-vert.net APT key to avoid warning
