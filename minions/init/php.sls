copy webtatic-release.rpm:
  file.managed:
    - name: ~/rpms/webtatic-release.rpm
    - source: salt://minions/rpm/webtatic-release.rpm
    - user: root
    - group: root
    - mode: 644

install webtatic-release:
  cmd.run:
    - name: rpm -Uvh ~/rpms/webtatic-release.rpm
    - name: rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
    - runas: root

install PHP:
  pkg.installed:
    - pkgs:
        - libmemcached-devel.x86_64
        - php71w-mysqlnd.x86_64
        - php71w-mbstring.x86_64
        - php71w-xml.x86_64
        - php71w-gd.x86_64
        - php71w-pecl-memcached.x86_64
        - php71w-pecl-redis.x86_64
        - php71w-fpm.x86_64
        - php71w-devel.x86_64
