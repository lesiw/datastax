#!/usr/bin/env sh

IP="$(hostname --ip-address)"

sed -ri 's/(endpoint_snitch:).*/\1 '"$SNITCH"'/' "$CASSANDRA_CONFIG"
sed -ri 's/(- seeds:).*/\1 "'"$IP"'"/' "$CASSANDRA_CONFIG"

BROADCAST_ADDRESS="$IP"
NATIVE_TRANSPORT_BROADCAST_ADDRESS="$IP"
BROADCAST_NATIVE_TRANSPORT_ADDRESS="$IP"
LISTEN_ADDRESS="$IP"

for name in \
    broadcast_address \
    cluster_name \
    listen_address \
    native_transport_address \
    native_transport_broadcast_address \
    num_tokens \
    start_native_transport \
    ;
do
    var=$(echo "$name" | tr 'a-z' 'A-Z')
    eval "val=\$$var"
    if [ "$val" ]; then
      sed -ri 's/^(# )?('"$name"':).*/\2 '"$val"'/' "$CASSANDRA_CONFIG"
    fi
done

for rackdc in dc rack; do
    var=$(echo "$rackdc" | tr 'a-z' 'A-Z')
    eval "val=\$$var"
    if [ "$val" ]; then
        sed -ri 's/^('"$rackdc"'=).*/\1 '"$val"'/' "$CASSANDRA_RACK_CONFIG"
    fi
done

exec "$@"
