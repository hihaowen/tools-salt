#
# 注意: 
#  1、升级之前必须确保 ngx 服务是停掉的
#  2、有些配置是写死的,需要手动更改,如 init_env
#  3、目录也要替换掉 salt://minions
#

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
    - name: /home/work/haowenzhi/modsecurity.tar.gz
    - source: salt://minions/files/modsecurity-2.9.1.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /home/work/haowenzhi/ && tar zxf modsecurity.tar.gz && mv modsecurity-2.9.1 modsecurity && cd modsecurity && chmod a+x ./autogen.sh && ./autogen.sh && ./configure --enable-standalone-module --disable-mlogc && make
    - unless: test -d /home/work/haowenzhi/modsecurity
    - require:
      - file: install_modsecurity

# 只编译,不安装 Nginx
make_nginx_from_source:
  file.managed:
    - name: /home/work/haowenzhi/nginx.tar.gz
    - source: salt://minions/files/nginx-1.10.1.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /home/work/haowenzhi && tar zxf nginx.tar.gz && mv nginx-1.10.1 nginx && cd nginx && ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_ssl_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' --add-module=/home/work/haowenzhi/modsecurity/nginx/modsecurity && make
    - unless: test -d /home/work/haowenzhi/nginx
    - require:
      - file: install_modsecurity

# 配置、bin执行文件初始化
# 注意: 这里会动态更改ngx配置,有一些写死的位置,不是很灵活,需要手动更改或执行完之后再 nginx -t 验证下
init_env:
  cmd.run:
    - name: mkdir -p /etc/nginx/modules/ && sed -i '62i ModSecurityEnabled on; ModSecurityConfig /etc/nginx/modsecurity/modsecurity.conf;' /etc/nginx/nginx.conf && cp /usr/sbin/nginx /usr/sbin/nginx_old_`date +"%Y%m%d%H"` && cp /home/work/haowenzhi/nginx/objs/nginx /usr/sbin/nginx && mkdir -p /etc/nginx/modsecurity && mkdir -p /home/work/logs/modsecurity && chown -R work:work /home/work/logs/modsecurity && chmod -R 0777 /home/work/logs/modsecurity && cp -R /home/tools/salt/minions/conf/modsecurity/* /etc/nginx/modsecurity/

# 启动 Nginx 服务
# start_ngx_service:
#  service.running:
#    - name: nginx
#    - enable: true
#    - runas: root
