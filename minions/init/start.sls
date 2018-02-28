staring php-fpm:
  service.running:
    - name: php-fpm
    - enable: true

staring ngx:
  service.running:
    - name: nginx
    - enable: true
