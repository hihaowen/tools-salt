reload ngx:
  cmd.run:
    - name: systemctl reload nginx.service
    - runas: root

reload fpm:
  cmd.run:
    - name: systemctl reload php-fpm.service
    - runas: root
