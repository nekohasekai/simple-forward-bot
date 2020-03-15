#!/bin/bash

if [ ! "$1" ]; then

  echo "[ init | update | run | log | start | stop | ... ]"

  exit

fi

if [ "$1" == "setup" ]; then

  git submodule init
  git submodule update
  mvn compile

elif [ "$1" == "init" ]; then

  echo ">> 写入服务"

  service="nekox"

  [ $2 ] && service="$2"

  cat >/etc/systemd/system/$service.service <<EOF
[Unit]
Description=Tooko
After=network.target
Wants=network.target

[Service]
Type=simple
WorkingDirectory=$(readlink -e ./)
ExecStart=/bin/bash nekox.sh run
Restart=on-failure
RestartPreventExitStatus=100

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload

  echo ">> 写入启动项"

  systemctl enable "$service" &>/dev/null

  echo "<< 完毕."

  exit

elif [ "$1" == "run" ]; then

  [ -d "target/classes" ] || mvn compile

  shift 1

  mvn exec:java -Dexec.mainClass="io.github.nekohasekai.sfb.SimpleBot" -Dexec.args="$*"

elif [ "$1" == "start" ]; then

  systemctl start nekox

  ./nekox.sh log

elif [ "$1" == "restart" ]; then

  systemctl restart nekox

  ./nekox.sh log

elif [ "$1" == "update" ]; then

  git fetch &>/dev/null

  if [ "$(git rev-parse HEAD)" = "$(git rev-parse FETCH_HEAD)" ]; then

    echo "<< 没有更新"

    exit 1

  fi

  echo ">> 检出更新 $(git rev-parse FETCH_HEAD)"

  git reset --hard FETCH_HEAD &>/dev/null

  mvn clean compile

  exit $?

elif [ "$1" == "log" ]; then

  journalctl -u nekox -f

elif [ "$1" == "logs" ]; then

  shift 1

  journalctl -u nekox --no-tail $@

else

  systemctl "$1" nekox

fi
