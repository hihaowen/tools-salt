init work:
  user.present:
    - name: work
    - createhome: true
    - password: $1$lF8I7Z9N$Fn6GSECyDuHUKOkZqdihU/

deploy bash & vim conf (root):
  file.recurse:
    - name: /root
    - source: salt://minions/conf/common-home
    - user: root
    - group: root
    - file_mode: 644
    - dir_mode: 755

deploy bash conf (root):
  file.managed:
    - name: /root/.bash_profile
    - source: salt://minions/conf/special-home/.bash_profile_root
    - user: root
    - group: root
    - mode: 644

deploy bash & vim conf (work):
  file.recurse:
    - name: /home/work
    - source: salt://minions/conf/common-home
    - user: work
    - group: work
    - file_mode: 644
    - dir_mode: 755

deploy bash conf (work):
  file.managed:
    - name: /home/work/.bash_profile
    - source: salt://minions/conf/special-home/.bash_profile
    - user: work
    - group: work
    - mode: 644
