# Before building your own image

Edit `CONFIG` file and set your local settings before doing anything.
Also download VMware-vSphere-Perl-SDK-6.5.0-4566394.x86\_64.tar.gz from VMWare (for ESX monitoring) into buildenv/files/other/vmware/ folder.

# MySQL/MariaDB on the host

There's no point trying to fight with Centreon Web installer.
The only way to get thru is to temporary create a network-enabled superadmin user and let him do what he wants:
```
CREATE USER 'root'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTIONS;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

Once the installation finished you can edit centreon user to relax host checking (because docker IP may change) and purge the superadmin:
```
DROP USER 'root'@'%';
USE mysql;
UPDATE user SET Host='172.17.%' WHERE User='centreon';
GRANT ALL PRIVILEGES ON centreon.* TO 'centreon'@'172.17.%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON centreon_storage.* TO 'centreon'@'172.17.%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

# After installation wizard

For some unknown reason Centreon gets stuck into an infinite wizard loop. Just restart the container.

# TODO

* Provide a proper package for nagios-plugins-bigdata
* Make Dockerfile modular using Python script and Jinja2 templates
* Import packages.le-vert.net APT key to avoid warning
