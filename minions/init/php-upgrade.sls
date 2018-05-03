remove old php version:
  cmd.run:
    - name: yum -y remove php*
    - runas: root

install webtatic-release:
  cmd.run:
    - name: rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    - name: rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
    - runas: root

install PHP:
  pkg.installed:
    - pkgs:
        - libmemcached-devel.x86_64
        - php72w-mysqlnd.x86_64
        - php72w-mbstring.x86_64
        - php72w-xml.x86_64
        - php72w-gd.x86_64
        - php72w-pecl-memcached.x86_64
        - php72w-pecl-redis.x86_64
        - php72w-fpm.x86_64
        - php72w-devel.x86_64
