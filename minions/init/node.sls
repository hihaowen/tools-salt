copy node setup shell:
  file.managed:
    - name: ~/nodesource-8.x-release-el7-1.noarch.rpm
    - source: salt://minions/rpm/nodesource-8.x-release-el7-1.noarch.rpm
    - user: root
    - group: root
    - mode: 644

install nodesource-release:
  cmd.run:
    - name: rpm -ivh ~/nodesource-8.x-release-el7-1.noarch.rpm
    - runas: root

clear yum cache:
  cmd.run:
    - name: rm -rf /var/cache/yum/
    - runas: root

install node:
  pkg.installed:
    - pkgs:
      - nodejs.x86_64

install pm2:
  cmd.run:
    - name: npm install pm2@latest -g
    - runas: root

#staring node:
#  cmd.run:
#    - name: /home/work/tengyue-fe/bin/pm2-production
#    - cwd: /home/work/tengyue-fe
#    - runas: work
