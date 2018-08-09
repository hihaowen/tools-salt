# 创建用于保存临时安装文件的目录
init tmp dir haowenzhi:
  file.directory:
    - name: /home/work/haowenzhi
    - makedirs: true
    - user: work
    - group: work
    - dir_mode: 755
    - file_mode: 644
