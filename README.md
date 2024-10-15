# AI4Industry @ UFSC

This repository contains auxiliary material for the Final Project of the [MultiAgent course](https://jomifred.github.io/mas/) of [Prof. Jomi Hubner](https://jomifred.github.io). The project description is [here](https://docs.google.com/document/d/1W6TgXikrYhW47doUN8UX8MfEgXsF8KFMu-lcJAeMM9Q/edit?usp=sharing).

Most of the source code comes from [AI4 Industry summer school hackathon](https://gitlab.emse.fr/ai4industry/hackathon/-/wikis/home).

To run the containers (simulator, GUI, NodeRed, ...):

```
docker compose up
```

- Plant Simulator: [http://localhost:8080/storageRack](http://localhost:8080/storageRack) (provides simulation, TD, and data for GUI)
- NodeRed: [http://127.0.0.1:1880](http://127.0.0.1:1880)
- Browser: [http://127.0.0.1:2000](http://127.0.0.1:2000) (a browser running in the containers network)
    - Simulation GUI should be open in this browser: [http://gui:3001](http://gui:3001)
- RDF server: [http://localhost:4000](http://localhost:4000)

![diagram](https://www.plantuml.com/plantuml/svg/XL7DQiCm3BxhAKHEWr7cDeCMdxgH3NPODzBSGWzkxNPcZbriPpsClViS9-rS2EnYOKdVZwIbyypwjb7WFgK-CiiQr8OB9uuu9m0WjHTsptO2iwf0kY0BaY5pkAuAg9riMiMyiHkSn0n0VMXb-DsG2QPbYXdD2ScpqB6rvkI47ReYu5oVPbUAT4P8B_Vu_bPM4DyWTQ48WbRiFDC79P0TXFOElm6mPahknBYFghWjdzPL1fWeDL9pfFbiFejo3wylgoAX6HBZaBnts4DYY1RDTWCnZDheBC3FrRHbyOpq_Znn-CMPQ-zL6FKhBkmlc_0c3RHh0AYx4w8L_9yDNErwkXXEkogBg374e9hm1VXUcHDoiH_1txNoJD5VB7LooNOadBcFhM6M1vQbqBnjr2y0)

<!-- @startuml
skinparam nodesep 70


interface "TD :8080" as STD
[simulator] - STD


[gui] -(0- [simulator] : ":3003"

[browser] -(0- [gui] : ":3001"

interface ":2000" as BPORT
BPORT - [browser]


rectangle agents {

 [alice] -(0- [simulator] : "TD+REST"
 interface "mind :3272" as AMIND
 [alice] - AMIND

 interface "mind :3273" as BMIND
 BMIND - [bob]
 [bob] -(0- [simulator] : REST
}

interface "RDF :4000" as RDFPORT
[ttlserver] - RDFPORT
[bob] -(0- [ttlserver] : RDF

[node red] -(0- [simulator] : "TD+REST"

interface ":1880" as NRDPORT
NRDPORT - [node red] : "flow def"

interface ":1880/ui" as NRDBPORT
[node red] - NRDBPORT : "dashboard"

@enduml -->

## MAS using Web of Things 

The directory `wot` has a JaCaMo application with agent Alice that reads and acts on the plant based on discovering the plant from TDs.

To run:

```
cd wot
docker compose up
```

## MAS using Knowledge Graph

The directory `kg` has a JaCaMo application with agent Bob that reads and acts on the plant based on discovering the plant from RDFs.

To run:

```
cd kg
docker compose up
```


## How to build the images

Note that the required images can be obtained from DockerHub. What follow is used to publish the images there.

```
cd ~/tmp
git clone https://gitlab.emse.fr/ai4industry/ai4industry simul

cd simul/use-case
docker build --tag=jomifred/ai4ind-simu:1.1 . 
docker image push jomifred/ai4ind-simu:1.1

cd ../gui

curl -LO https://raw.githubusercontent.com/jomifred/ai4ind-ufsc/refs/heads/main/docker-files/gui/Dockerfile
docker build --tag=jomifred/ai4ind-gui:1.1 . 
docker image push jomifred/ai4ind-gui:1.1
```

Build the NodeRed with WebOfThings:

```
cd ai4ind-ufsc/docker-files/nodered
docker build --tag=jomifred/ai4ind-nodered . 
docker image push jomifred/ai4ind-nodered
```

## Notes about RDF http server

RDF server provides the RDF descriptions of the plan for applications. It is based on Apache httpd (directory `ttl-server`).

Changes I made on `httpd.conf` (see `my-httpd.conf`):
- add `index.ttl` in `DirectoryIndex` (line 299)
- uncomment `LoadModule negotiation_module modules/mod_negotiation.so` (line 192)
- add `MultiViews` options (line 279) 

In the ttl files (copied from https://gitlab.emse.fr/ai4industry/kg), I replaced `../../../simu` by `http://simulator:8080`.
