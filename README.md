# GraphAware neo4j 2 elastic

Docker Compose setup for testing  Elasticsearch and Neo4j.

The following will be run and configured automatically :
 
* Elasticsearch 7.10.0 listening on port 9200
* Neo4j 3.5.14 listening on port 7474
* kibana on port 5601
* GraphAware [neo4j-to-elasticsearch](https://github.com/graphaware/neo4j-to-elasticsearch) plugin installed and configured
* neo4j APOC and GraphDataScience plugins
* CSV sources for running the examples installed in the `data/import` directory of Neo4j and the server is
configured to allow loading external files from this path
* A `_query` directory providing json files of all the queries from the demo


for other version check https://repo1.maven.org/maven2/com/graphaware/neo4j/neo4j-to-elasticsearch
 
### Setup

```bash
# Run the stack with Docker Compose
docker-compose up
```

- Neo4j will be available on port 7474 http://localhost:7474/browser/ (no pw needed)
- Elasticsearch on port 9200 http://localhost:9200. 
- kibana on port 5601 http://localhost:5601/


```text
create
(leyla: Officer {name:"Leyla Aliyeva"})-[:IOO_BSD]->(ufu:Company {name:"UF Universe Foundation"}),
(mehriban: Officer {name:"Mehriban Aliyeva"})-[:IOO_PROTECTOR]->(ufu),
(arzu: Officer {name:"Arzu Aliyeva"})-[:IOO_BSD]->(ufu),
(mossack_uk: Client {name:"Mossack Fonseca & Co (UK)"})-[:REGISTERED]->(ufu),
(mossack_uk)-[:REGISTERED]->(fm_mgmt: Company {name:"FM Management Holding Group S.A."}),

(leyla)-[:IOO_BSD]->(kingsview:Company {name:"Kingsview Developents Limited"}),
(leyla2: Officer {name:"Leyla Ilham Qizi Aliyeva"}),
(leyla3: Officer {name:"LEYLA ILHAM QIZI ALIYEVA"})-[:HAS_SIMILIAR_NAME]->(leyla),
(leyla2)-[:HAS_SIMILIAR_NAME]->(leyla3),
(leyla2)-[:IOO_BENEFICIARY]->(exaltation:Company {name:"Exaltation Limited"}),
(leyla3)-[:IOO_SHAREHOLDER]->(exaltation),
(arzu2:Officer {name:"Arzu Ilham Qizi Aliyeva"})-[:IOO_BENEFICIARY]->(exaltation),
(arzu2)-[:HAS_SIMILIAR_NAME]->(arzu),
(arzu2)-[:HAS_SIMILIAR_NAME]->(arzu3:Officer {name:"ARZU ILHAM QIZI ALIYEVA"}),
(arzu3)-[:IOO_SHAREHOLDER]->(exaltation),
(arzu)-[:IOO_BSD]->(exaltation),
(leyla)-[:IOO_BSD]->(exaltation),
(arzu)-[:IOO_BSD]->(kingsview),

(redgold:Company {name:"Redgold Estates Ltd"}),
(:Officer {name:"WILLY & MEYRS S.A."})-[:IOO_SHAREHOLDER]->(redgold),
(:Officer {name:"LONDEX RESOURCES S.A."})-[:IOO_SHAREHOLDER]->(redgold),
(:Officer {name:"FAGATE MINING CORPORATION"})-[:IOO_SHAREHOLDER]->(redgold),
(:Officer {name:"GLOBEX INTERNATIONAL LLP"})-[:IOO_SHAREHOLDER]->(redgold),
(:Client {name:"Associated Trustees"})-[:REGISTERED]->(redgold)
```

CALL ga.es.queryNode('{"query": {"fuzzy": {"name": "leyl"}}}') YIELD node, score RETURN node, score