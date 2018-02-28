{% for DIR in ['~/rpms','~/repos'] %}
init root dir {{ DIR }}:
  file.directory:
    - name: {{ DIR }}
    - makedirs: true
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
{% endfor %}

# 创建日志目录
{% for DIR in ['/home/work/logs/nginx', '/home/work/logs/php-fpm', '/home/work/logs/php', '/home/work/logs/node'] %}
init log dir {{ DIR }}:
  file.directory:
    - name: {{ DIR }}
    - makedirs: true
    - user: work
    - group: work
    - dir_mode: 755
    - file_mode: 644
{% endfor %}

init etc git:
  git.latest:
    - name: https://github.com/hihaowen/server_configs.git
    - target: /root/repos/conf
    #- identity: /home/work/.ssh/id_rsa

{% for DIR in ['nginx', 'php.d', 'php-fpm.conf', 'php-fpm.d', 'php.ini', 'php-zts.d', 'logrotate.conf', 'logrotate.d'] %}
delete conf {{ DIR }}:
  file.absent:
    - name: /etc/{{ DIR }}

ln conf {{ DIR }}:
  file.symlink:
    - name: /etc/{{ DIR }}
    - target: /root/repos/conf/basic/{{ DIR }}
    - force: true
    - user: root
    - group: root
{% endfor %}
