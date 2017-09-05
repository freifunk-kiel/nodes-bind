#!/bin/bash

TMP="tempdir"
NODES="https://mesh.freifunk.in-kiel.de/nodes.json"
TLD=knoten.ffki

IsValidHostname () {
  #[a-z] would include umlauts like äöü if LOCALE is set to german
  REGEX="^[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0-9-]+$"
  if [[ "$@" =~ $REGEX ]] ; then
    return 0
  else
    # Not valid
    return 1
  fi
}

mkdir -p $TMP
cd $TMP
wget $NODES 
jq -r '.nodes[]|.nodeinfo|select(.network.addresses|length > 0)|.network.addresses[] +" " +.hostname|.' nodes.json | grep -E "^fda1:384a:74de:4242" > nodelist
cat nodelist | while read k; do
  IP6="$(echo $k | cut -d" " -f1)"
  KNOTEN="$(echo $k | cut -d" " -f2-99|tr _ -|tr . -|tr " " -|tr '[:upper:]' '[:lower:]'|sed 's/ä/ae/;s/ö/oe/;s/ü/ue/;s/ß/ss/g')"
  IsValidHostname "$KNOTEN"
  if [ $? == 0 ]; then
    echo -e "$KNOTEN.$TLD \t\t\t\t\t86400 \tIN \tAAAA \t$IP6"
  fi
done
