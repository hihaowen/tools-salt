#
# 注意: 
#  1、升级之前必须确保 ngx 服务是停掉的
#  2、有些配置是写死的,需要手动更改,如 init_env
#  3、目录也要替换掉 salt://minions
#

copy minions/sh/env_global.sh:
  file.managed:
    - name: /etc/profile.d/env-global.sh
    - source: salt://minions/sh/env_global.sh
    - user: root
    - group: root
    - mode: 644

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
{% for DIR in ['/home/work/logs/nginx', '/home/work/logs/modsecurity'] %}
init log dir {{ DIR }}:
  file.directory:
    - name: {{ DIR }}
    - makedirs: true
    - user: work
    - group: work
    - dir_mode: 755
    - file_mode: 644
{% endfor %}

# 安装依赖软件
install httpd-devel:
    pkg.installed:
      - name: httpd-devel

install libxml2:
    pkg.installed:
      - name: libxml2

install libxml2-devel:
    pkg.installed:
      - name: libxml2-devel

# 创建用于保存临时安装文件的目录
init tmp dir opt:
  file.directory:
    - name: /home/work/opt
    - makedirs: true
    - user: work
    - group: work
    - dir_mode: 755
    - file_mode: 644

# 源码安装 ModSecurity
install modsecurity:
  file.managed:
    - name: /home/work/opt/modsecurity.tar.gz
    - source: salt://minions/files/modsecurity-2.9.1.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /home/work/opt/ && tar zxf modsecurity.tar.gz && mv modsecurity-2.9.1 modsecurity && cd modsecurity && chmod a+x ./autogen.sh && ./autogen.sh && ./configure --enable-standalone-module --disable-mlogc && make
    - unless: test -d /home/work/opt/modsecurity
    - require:
      - file: init tmp dir opt

# 备份原始二进制文件
backup old ngx bin:
  cmd.run:
    - name: cp /usr/sbin/nginx /usr/sbin/nginx_ori_`date +"%Y%m%d%H"`
    - require:
      - file: install modsecurity

# 编译并覆盖安装 Nginx
make nginx from source:
  file.managed:
    - name: /home/work/opt/nginx.tar.gz
    - source: salt://minions/files/tengine-2.2.2.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /home/work/opt && tar zxf nginx.tar.gz && mv tengine-2.2.2 nginx && cd nginx && ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --add-module=/home/work/opt/modsecurity/nginx/modsecurity && make && make install
    - unless: test -d /home/work/opt/nginx

# 覆盖原有的ngx配置
init etc git:
  git.latest:
    - name: https://github.com/hihaowen/server_configs.git
    - target: /root/repos/conf

{% for DIR in ['nginx', 'logrotate.conf', 'logrotate.d'] %}
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

# 启动 Nginx 服务
# start_ngx_service:
#  service.running:
#    - name: nginx
#    - enable: true
#    - runas: root
