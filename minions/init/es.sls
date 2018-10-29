{% for DIR in ['/home/work/logs','/home/work/data','/home/work/repos'] %}
init log dir {{ DIR }}:
  file.directory:
    - name: {{ DIR }}
    - makedirs: true
    - user: work
    - group: work
    - dir_mode: 755
    - file_mode: 644
{% endfor %}

# 安装失败的话参考 https://www.cnblogs.com/miao-zp/p/6003160.html
install ES:
 pkg.installed:
   - pkgs:
       - elasticsearch

init etc git:
  git.latest:
    - name: https://github.com/hihaowen/es_configs.git
    - target: /home/work/repos/production-etc

delete conf /etc/elasticsearch:
  file.absent:
    - name: /etc/elasticsearch

ln conf /etc/elasticsearch:
  file.symlink:
    - name: /etc/elasticsearch
    - target: /home/work/repos/production-etc/etc-elasticsearch
    - force: true
    - user: root
    - group: root

delete conf /usr/share/elasticsearch/plugins/ik/config:
  file.absent:
    - name: /usr/share/elasticsearch/plugins/ik/config

ln conf /usr/share/elasticsearch/plugins/ik/config:
  file.symlink:
    - name: /usr/share/elasticsearch/plugins/ik/config
    - target: /home/work/repos/production-etc/ik-config
    - force: true
    - user: root
    - group: root
