#!/bin/bash

set -e

echo `date` $0
index_name="default-index-node"
( # run concurrent to elasticsearch:
    while ! ( /healthcheck.sh ) ;do echo expect to become healthy; sleep 5; done
    echo XXX $0 initialisation finished, service is healthy
    curl -XPUT "es01:9200/default-index-node"
    echo XXX $0 index created
    curl -XPUT "es01:9200/default-index-node/_mapping" -H "Content-Type: application/json" -d "@elasticsearch_setting_mapping.json"
    echo XXX $0 mapping schema defined
) &

echo $0


exec bin/elasticsearch