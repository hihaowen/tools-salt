# ngx
init ngx repo:
  file.managed:
    - name: /etc/yum.repos.d/nginx.repo
    - source: salt://minions/yum.repos.d/nginx.repo
    - user: root
    - group: root
    - mode: 644

install ngx:
  pkg.installed:
    - name: nginx

install epel-release:
  pkg.installed:
    - name: epel-release

staring ngx:
   service.running:
     - name: nginx
     - enable: true
