#
# 注意: 
#  1、升级之前必须确保 ngx 服务是停掉的
#  2、有些配置是写死的,需要手动更改,如 init_env
#  3、目录也要替换掉 salt://minions
#

# 创建用于保存临时安装文件的目录
init tmp dir haowenzhi:
  file.directory:
    - name: /home/work/haowenzhi
    - makedirs: true
    - user: work
    - group: work
    - dir_mode: 755
    - file_mode: 644

# 源码安装 ModSecurity
install_modsecurity:
  file.managed:
    - name: /home/work/haowenzhi/ModSecurity.tar.gz
    - source: salt://minions/files/ModSecurity.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /home/work/haowenzhi/ && tar zxf ModSecurity.tar.gz && cd ModSecurity && chmod a+x ./build.sh && ./build.sh && ./configure && make
    - unless: test -d /home/work/haowenzhi/ModSecurity
    - require:
      - file: install_modsecurity

# 安装 Nginx Connector
install_modsecurity_ngx_connector:
  file.managed:
    - name: /home/work/haowenzhi/ModSecurity-Nginx.tar.gz
    - source: salt://minions/files/ModSecurity-Nginx.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /home/work/haowenzhi/ && tar zxf ModSecurity-Nginx.tar.gz
    - unless: test -d /home/work/haowenzhi/ModSecurity-nginx
    - require:
      - file: install_modsecurity

# 只编译,不安装 Nginx
make_nginx_from_source:
  file.managed:
    - name: /home/work/haowenzhi/nginx-1.10.1.tar.gz
    - source: salt://minions/files/nginx-1.10.1.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /home/work/haowenzhi && tar zxf nginx-1.10.1.tar.gz && cd nginx-1.10.1 && ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_ssl_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie' --add-dynamic-module=/home/work/haowenzhi/ModSecurity-nginx && make
    - unless: test -d /home/work/haowenzhi/nginx-1.10.1
    - require:
      - file: install_modsecurity_ngx_connector

# 配置、bin执行文件初始化
# 注意: 这里会动态更改ngx配置,有一些写死的位置,不是很灵活,需要手动更改或执行完之后再 nginx -t 验证下
init_env:
  file.managed:
    - name: /etc/nginx/modules/ngx_http_modsecurity_module.so
    - source: /home/work/haowenzhi/nginx-1.10.1/objs/ngx_http_modsecurity_module.so
    - user: root
    - group: root
    - mode: 0755
    - unless: test -f /etc/nginx/modules/ngx_http_modsecurity_module.so
    - require:
      - file: make_nginx_from_source
  cmd.run:
    - name: mkdir -p /etc/nginx/modules/ && sed -i '1i load_module modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf && sed -i '63i modsecurity on; modsecurity_rules_file /etc/nginx/modsecurity/modsecurity.conf;' /etc/nginx/nginx.conf && cp /usr/sbin/nginx /usr/sbin/nginx_old_`date +"%Y%m%d%H"` && cp /home/work/haowenzhi/nginx-1.10.1/objs/nginx /usr/sbin/nginx && mkdir -p /etc/nginx/modsecurity && mkdir -p /home/work/logs/modsecurity && cp -R /home/tools/salt/minions/conf/modsecurity/* /etc/nginx/modsecurity/

# 启动 Nginx 服务
# start_ngx_service:
#  service.running:
#    - name: nginx
#    - enable: true
#    - runas: root
