#!/bin/bash
#
#
C="unknown";
if [[ "$1" = "asafe" ]]
then
  C="cc16";
elif [[ ".btc.bir.pny.sapp.esk." = *".$1."* ]]
#need to ln -s these ^^^
then
  C="cc20";
elif [[ "$1" = "faucex" ]]
then
  C="faucex";
elif [[ "$1" = "holdip" ]]
then
  C="holdip";
fi
#
#

#`x faucex` (enter into one of these containers. exit to leave)
if [[ ".faucex.holdip.cc20.mn20.cc16.mn16." = *".$1."* && "$2" = "" ]]
then
  docker exec --user root -it $1 /bin/bash
#
#
#`x ls` (list the containers)
#`docker restart mn20` (will restart, make sure all coins are off inside first)
elif [ "$1" = "ls" ]
then
  docker ps -a
#
#
#`x top` (show all running via top)
elif [ "$1" = "top" ]
then
  top -o COMMAND -p `pgrep "faucex|faucex-router|faucex-relay|faucex-command|faucex-monitor|\.cmd$|\.daemon$|\.coinsjs$|sendmail" | tr "\\n" "," | sed 's/,$//'`
#
#`x faucex sendmail on` (turn sendmail on in the background as a daemon)
elif [ "$2 $3" = "sendmail on" ]
then
  docker exec -it $C sh -c "sendmail -bd"
#
#
#`x asafe h` (show help)
elif [ "$2 $3" = "h " ]
then
  docker exec -it $C sh -c "$1"
#
#
#`x asafe @ ls -l /home/` (run a command from the host without entering the container)
elif [ "$2" = "@" ]
then
  docker exec -it $C sh -c "$3 $4 $5 $6 $7 $8 $9"
#
#
#`x faucex on` (turn faucex on as a daemon)
elif [ "$1 $2" = "faucex on" ]
then
  if pidof faucex > /dev/null
  then
    echo "faucex is already running."
  else
    docker exec -d $C sh -c "/usr/bin/node /home/private_js/faucex.js --max-old-space-size=2048"
  fi
#
#
#`x faucex off` (turn faucex daemon of after 30 seconds)
elif [ "$1 $2" = "faucex off" ]
then
  rm -f /home/SETTINGS/shutdown/faucex || true && touch /home/SETTINGS/shutdown/faucex
#
#
#`x faucex router on` (turn faucex-router on as a daemon. must be done before admin can start faucex up)
elif [ "$1 $2 $3" = "faucex router on" ]
then
  if pidof faucex-router > /dev/null
  then
    echo "faucex-router is already running."
  else
    docker exec -d $C sh -c "/usr/bin/node /home/private_js/server/router.js $4"
  fi
#
#
#`x faucex router off` (turn off faucex router instantly)
elif [ "$1 $2 $3" = "faucex router off" ]
then
  rm -f /home/SETTINGS/shutdown/faucex-router || true && touch /home/SETTINGS/shutdown/faucex-router
#
#
#`x holdip faucex relay on` (turn on faucex cocpit admin pannel message relay daemon)
elif [ "$1 $2 $3 $4" = "holdip faucex relay on" ]
then
  if pidof faucex-relay > /dev/null
  then
    echo "faucex-relay is already running."
  else
    docker exec -d $C sh -c "/usr/bin/node /home/relay.js --max-old-space-size=2048"
  fi
#
#
#`x holdip relay off` (turn off faucex relay instantly)
elif [ "$1 $2 $3 $4" = "holdip faucex relay off" ]
then
  rm -f /home/SETTINGS/shutdown/faucex-relay || true && touch /home/SETTINGS/shutdown/faucex-relay
#
#
#`x asafe on` (turn coins.js on for asafe coin. asafes coin daemon must be on first)
elif [ "$2" = "on" ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  N=$(ls -1q /home/$COIN/problem_tx/ | wc -l)
  if (( N > 0 ));
  then
    echo "$1 will not start until you first deal with $N file(s) in /home/$COIN/problem_tx"
  else
    cp /home/block.js /home/$COIN/
    cp /home/tx.js /home/$COIN/
    docker exec -d $C sh -c "/usr/bin/node /home/$COIN/app.js"
  fi
#
#
#`x asafe off` (turn coin.js off for asafe coin. takes 30 seconds)
elif [ "$2" = "off" ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  echo 'wait 60 seconds (full shutdown) ...'
  rm -f /home/$COIN/tx.js /home/$COIN/block.js || true
  rm -f /home/$COIN/shutdown/this || true && touch /home/$COIN/shutdown/this
  sleep 60
  echo 'done.'
#
#
#`x asafe d on` (turn asafe daemon on)
elif [ "$2 $3" = "d on" ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  docker exec -d $C sh -c "$COIN.daemon -datadir=/home/$COIN/data -daemon 1> /dev/null"
  #nice -n 19 
#
#
#`x asafe d off` (turn asafe daemon off)
elif [ "$2 $3" = "d off" ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  if pgrep -f $COIN.daemon &> /dev/null 2>&1; then
    echo 'wait 60 seconds (full shutdown) ...'
    rm -f /home/$COIN/tx.js /home/$COIN/block.js || true
    rm -f /home/$COIN/shutdown/this || true && touch /home/$COIN/shutdown/this
    sleep 60
    docker exec -it $C sh -c "$COIN.cli -datadir=/home/$COIN/data stop 1> /dev/null"
    echo 'done.'
  else
    docker exec -it $C sh -c "$COIN.cli -datadir=/home/$COIN/data stop 1> /dev/null"
    echo 'done.'
  fi
#
#
#`x asafe up` (checks if coins.js for asafe is up. if it is the pid will be printed)
elif [ "$2 $3" = "up " ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  docker exec -it $C sh -c "pgrep -f $COIN.coin"
#
#
#`x asafe d up` (checks if the daemon for asafe is up. if it is the pid will be printed)
elif [ "$2 $3" = "d up" ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  docker exec -it $C sh -c "pgrep -f $COIN.daemon"
#
#
#`x asafe w` (watches the debug log for asafe coin in real time)
elif [ "$2 $3" = "w " ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  docker exec -it $C sh -c "watch tail /home/$COIN/data/debug.log"
#
#
#`x asafe t` (traces asafe daemons inner workings)
elif [ "$2 $3" = "t " ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  docker exec -it $C sh -c "strace -p $(pgrep -f $COIN.daemon)"
#
#
#`x asafe p` (prints the current syncing progress. 1.00000000 is 100%) <<<< needs work
elif [ "$2 $3" = "p " ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  docker exec -it $C sh -c "s=$(s=$(grep 'progress=' /home/$COIN/data/debug.log | tail -1) && awk -F'progress=' '{print $NF}' <<< $s) && awk -F' ' '{print $1}' <<< $s"
#
#
#`x asafe q help` (RPC access for asafe)
elif [ "$2" = "q" ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  docker exec -it $C sh -c "$COIN.cli -datadir=/home/$COIN/data $3 $4 $5 $6 $7 $8"
#
#
#`x asafe cmd on` (turn on coin command for asafe. this alows the cockpit to send commands to this coin)
elif [ "$2 $3" = "cmd on" ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  docker exec -d $C sh -c "/usr/bin/node /home/$COIN/coin.command.js"
#
#
#`x asafe cmd off` (switch off asafe coin command instantly)
elif [ "$2 $3" = "cmd off" ]
then
  COIN=$(echo $1 | tr '[:lower:]' '[:upper:]')
  rm -f /home/SETTINGS/shutdown/$COIN.cmd || true && touch /home/SETTINGS/shutdown/$COIN.cmd
#
#
#`x faucex command on` (turn on faucex command. this alows the cockpit to send commands to faucex)
elif [ "$1 $2 $3" = "faucex command on" ]
then
  if pidof faucex-command > /dev/null
  then
    echo "faucex-command is already running."
  else
    docker exec -d $C sh -c "/usr/bin/node /home/private_js/faucex.command.js"
  fi
#
#
#`x faucex command off` (switch off faucex command instantly)
elif [ "$2 $3" = "command off" ]
then
  rm -f /home/SETTINGS/shutdown/faucex-command || true && touch /home/SETTINGS/shutdown/faucex-command
#
#
#`x faucex monitor on` (runs as a daemon and checks restarts router/relay/command if crashed every 20 seconds)
elif [ "$1 $2 $3" = "faucex monitor on" ]
then
  /root/.nvm/versions/node/v11.15.0/bin/node /home/private_js/faucex.monitor.d.js on
#
#
#`x faucex command off` (instantly stops monitoring for needed restarts)
elif [ "$1 $2 $3" = "faucex monitor off" ]
then
  /root/.nvm/versions/node/v11.15.0/bin/node /home/private_js/faucex.monitor.d.js off
#
#
else
  echo "

  help:

  x asafe h                         prints help for asafe
  x btc h                           prints help for btc ... etc

  x ls                              list the containers
  docker restart mn20               make sure all coins are off inside first
  x top                             show all running via top

  x faucex                          enter into faucex container, exit to leave
  x holdip                          enter into holdip container, exit to leave
  x cc16                            enter into cc16 container, exit to leave
  x mn16                            enter into mn16 container, exit to leave
  x cc20                            enter into cc20 container, exit to leave
  x mn20                            enter into mn20 container, exit to leave

  x asafe @ ls -l /home/            run a command from the host without entering the container (by coin)
  x faucex @ ls -l /home/           run a command from the host without entering the container
  x holdip @ ls -l /home/           run a command from the host without entering the container

  TURNING THINGS ON IN ORDER:

  x faucex sendmail on              runs in the background as a daemon
  x faucex router on                runs faucex-router as a daemon. must be done before admin can start faucex up manually
  x holdip faucex relay on          runs faucex cockpit admin pannel message relay daemon through holdip
  x faucex on                       runs faucex as a daemon
  x faucex command on               runs faucex.command.js as a daemon (allows cockpit interaction with faucex)
  x faucex monitor on               runs as a daemon and checks restarts router/relay/command if crashed every 20 seconds
  (optional:)
  x asafe d on                      runs asafe daemon
  x asafe on                        runs coins.js for asafe as a daemon
  x asafe cmd on                    turn coin.command.js on

  OFF ...

  x faucex monitor off              instantly stops monitoring for needed restarts
  x holdip faucex relay off         instantly dissconnect the cockpit
  x faucex off                      gracefull shutdown after 30 seconds
  x faucex router off               instantly makes the site unreachable
  x faucex command off              instantly stops cockpit command functionallity with faucex
  x asafe cmd off                   instantly stops cockpit command functionallity
  x asafe off                       gracefull shutdown after 30 seconds
  x asafe d off                     stops the coin daemon

  INSTALL THIS SCRIPT:

  cd && chmod +x /home/x && ln -s /home/x /usr/bin/x

  DEBUG: C=$C 1=$1 2=$2 3=$3 4=$4
  "
fi
