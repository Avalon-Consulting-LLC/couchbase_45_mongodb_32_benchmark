# Couchbase setup

## Basic Setup

```vagrant up --provider=aws```

## Final settings

There are some manual steps to enable a few final settings on each Couchbase Server instance:

1. curl \<host\>:9102/settings -u couchbase:couchbase | python -m json.tool > settings.json
2. vim settings.json
3. Make changes listed below
3. curl \<host\>:9102/settings -u couchbase:couchbase -d  @settings.json

Settings to change:

* indexer.settings.maxVBQueueLength = 5000
* indexer.settings.wal_size = 40960
* indexer.settings.max_cpu_percent = 1600

