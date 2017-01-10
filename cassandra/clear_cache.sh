#!/bin/bash

export CASSANDRA_NODES=9
export prefix="cassandra"

for i in $(seq 0 $(($CASSANDRA_NODES - 1))); do
  h="cassandra$(printf '%02d' $((i + 1)))"
  vagrant ssh $h -c "sync; echo 3 | sudo tee /proc/sys/vm/drop_caches"
done
