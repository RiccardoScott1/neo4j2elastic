# GraphAware neo4j 2 elastic

Docker Compose setup for testing  Elasticsearch and Neo4j.

The following will be run and configured automatically :
 
* Elasticsearch 5.1.1 listening on port 9200 and the `Graph-Aided Search` plugin installed
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

#### Add the schema constraints in Neo4j

Open up the browser and run these 2 cypher statements :

```bash
CREATE CONSTRAINT ON (n:Movie) ASSERT n.objectId IS UNIQUE;

CREATE CONSTRAINT ON (n:User) ASSERT n.objectId IS UNIQUE;
```

Create the Users from the CSV dataset :

```bash
USING PERIODIC COMMIT 500
LOAD CSV FROM "file:///u.user" AS line FIELDTERMINATOR '|'
CREATE (:User {objectId: toInt(line[0]), age: toInt(line[1]), gender: line[2], occupation: line[3]});
```

Create the Movies :

```bash
USING PERIODIC COMMIT 500
LOAD CSV FROM "file:///u.item" AS line FIELDTERMINATOR '|'
CREATE (:Movie {objectId: toInt(line[0]), title: line[1], date: line[2], imdblink: line[4]});
```

Create the Likes relationships with the ratings as relationship properties :

```bash
USING PERIODIC COMMIT 500
LOAD CSV FROM "file:///u.data" AS line FIELDTERMINATOR '\t'
MATCH (u:User {objectId: toInt(line[1])})
MATCH (p:Movie {objectId: toInt(line[0])})
CREATE UNIQUE (u)-[:LIKES {rate: ROUND(toFloat(line[2])), timestamp: line[3]}]->(p);
```

#### Query 1 : Simple search for movies with `love` in the title

```bash
GET /neo4j-index/_search?pretty HTTP/1.1
Content-Length: 108
Accept-Encoding: gzip, deflate
Host: 192.168.99.100:9200
Accept: application/json
User-Agent: HTTPie/0.9.2
Connection: keep-alive
Content-Type: application/json

{
  "size": 3,
  "query" : {
      "bool": {
        "should": [{"match": {"title": "love"}}]
      }
  }
}


HTTP/1.1 200 OK
Content-Type: application/json; charset=UTF-8
Content-Length: 1189

{
  "took" : 6,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 29,
    "max_score" : 2.9627202,
    "hits" : [ {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "1297",
      "_score" : 2.9627202,
      "_source" : {
        "date" : "01-Jan-1994",
        "imdblink" : "http://us.imdb.com/M/title-exact?Love%20Affair%20(1994)",
        "title" : "Love Affair (1994)",
        "objectId" : "1297"
      }
    }, {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "1446",
      "_score" : 2.919132,
      "_source" : {
        "date" : "01-Jan-1995",
        "imdblink" : "http://us.imdb.com/M/title-exact?Bye%20Bye,%20Love%20(1995)",
        "title" : "Bye Bye, Love (1995)",
        "objectId" : "1446"
      }
    }, {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "535",
      "_score" : 2.6663055,
      "_source" : {
        "date" : "23-May-1997",
        "imdblink" : "http://us.imdb.com/M/title-exact?Addicted%20to%20Love%20%281997%29",
        "title" : "Addicted to Love (1997)",
        "objectId" : "535"
      }
    } ]
  }
}
```

#### Query2 : Filter out negatively rated movies from the ES results by using a Cypher filter :

```bash
GET /neo4j-index/_search?pretty HTTP/1.1
Content-Length: 351
Accept-Encoding: gzip, deflate
Host: 192.168.99.100:9200
Accept: application/json
User-Agent: HTTPie/0.9.2
Connection: keep-alive
Content-Type: application/json

{
  "size": 3,
  "query" : {
      "bool": {
        "should": [{"match": {"title": "love"}}]
      }
  },
  "gas-filter" :{
      "name": "SearchResultCypherFilter",
      "query": "MATCH (n:User)-[r:LIKES]->(m) WITH m, avg(r.rate) as avg_rate where avg_rate < 3 RETURN m.objectId as id",
      "exclude": true,
      "keyProperty": "objectId"
  }
}


HTTP/1.1 200 OK
Content-Type: application/json; charset=UTF-8
Content-Length: 1189

{
  "took" : 4,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 29,
    "max_score" : 2.9627202,
    "hits" : [ {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "1297",
      "_score" : 2.9627202,
      "_source" : {
        "date" : "01-Jan-1994",
        "imdblink" : "http://us.imdb.com/M/title-exact?Love%20Affair%20(1994)",
        "title" : "Love Affair (1994)",
        "objectId" : "1297"
      }
    }, {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "1446",
      "_score" : 2.919132,
      "_source" : {
        "date" : "01-Jan-1995",
        "imdblink" : "http://us.imdb.com/M/title-exact?Bye%20Bye,%20Love%20(1995)",
        "title" : "Bye Bye, Love (1995)",
        "objectId" : "1446"
      }
    }, {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "535",
      "_score" : 2.6663055,
      "_source" : {
        "date" : "23-May-1997",
        "imdblink" : "http://us.imdb.com/M/title-exact?Addicted%20to%20Love%20%281997%29",
        "title" : "Addicted to Love (1997)",
        "objectId" : "535"
      }
    } ]
  }
}

```

#### Query 3 : Exclude movies already rated by the User

We randomly choose the User with id `12`, this logic should be computed at the application level

```bash
GET /neo4j-index/_search?pretty HTTP/1.1
Content-Length: 330
Accept-Encoding: gzip, deflate
Host: 192.168.99.100:9200
Accept: application/json
User-Agent: HTTPie/0.9.2
Connection: keep-alive
Content-Type: application/json

{
  "size": 3,
   "query" : {
       "bool": {
         "should": [{"match": {"title": "love"}}]
       }
   },
   "gas-filter" :{
        "name": "SearchResultCypherFilter",
        "query": "MATCH (n:User {objectId: 12})-[r:LIKES]->(m) RETURN m.objectId as id",
        "exclude": true,
        "keyProperty": "objectId"
   }
}


HTTP/1.1 200 OK
Content-Type: application/json; charset=UTF-8
Content-Length: 1189

{
  "took" : 9,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 29,
    "max_score" : 2.9627202,
    "hits" : [ {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "1297",
      "_score" : 2.9627202,
      "_source" : {
        "date" : "01-Jan-1994",
        "imdblink" : "http://us.imdb.com/M/title-exact?Love%20Affair%20(1994)",
        "title" : "Love Affair (1994)",
        "objectId" : "1297"
      }
    }, {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "1446",
      "_score" : 2.919132,
      "_source" : {
        "date" : "01-Jan-1995",
        "imdblink" : "http://us.imdb.com/M/title-exact?Bye%20Bye,%20Love%20(1995)",
        "title" : "Bye Bye, Love (1995)",
        "objectId" : "1446"
      }
    }, {
      "_index" : "neo4j-index",
      "_type" : "Movie",
      "_id" : "535",
      "_score" : 2.6663055,
      "_source" : {
        "date" : "23-May-1997",
        "imdblink" : "http://us.imdb.com/M/title-exact?Addicted%20to%20Love%20%281997%29",
        "title" : "Addicted to Love (1997)",
        "objectId" : "535"
      }
    } ]
  }
}
```
