# GraphAware neo4j 2 elastic

Docker Compose setup for testing  Elasticsearch and Neo4j.

The following will be run and configured automatically :
 
* Elasticsearch 5.1.1 listening on port 9200
* Neo4j 3.5.14 listening on port 7474
* GraphAware [neo4j-to-elasticsearch](https://github.com/graphaware/neo4j-to-elasticsearch) plugin installed and configured
* CSV sources for running the examples installed in the `data/import` directory of Neo4j and the server is
configured to allow loading external files from this path
* A `_query` directory providing json files of all the queries from the demo


for other version check https://repo1.maven.org/maven2/com/graphaware/neo4j/neo4j-to-elasticsearch
 
### Setup

```bash
# Run the stack with Docker Compose
docker-compose up
```

Neo4j will be available on your docker host ip (generally `localhost` on Linux and `192.168.99.100` on OS X) on port 7474 and Elasticsearch on port 9200.
