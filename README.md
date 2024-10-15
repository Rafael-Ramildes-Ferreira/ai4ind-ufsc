# AI4Industry @ UFSC

This repository contains auxiliary material for the Final Project of the [MultiAgent course](https://jomifred.github.io/mas/) of [Prof. Jomi Hubner](https://jomifred.github.io). The project description is [here](https://docs.google.com/document/d/1W6TgXikrYhW47doUN8UX8MfEgXsF8KFMu-lcJAeMM9Q/edit?usp=sharing).


To run the containers (simulator, GUI, NodeRed, ...):

```
docker compose up
```

- Plant Simulator: [http://localhost:8080/storageRack](http://localhost:8080/storageRack) (provides simulation, TD, and data for GUI)
- NodeRed: [http://127.0.0.1:1880](http://127.0.0.1:1880)
- Browser: [http://127.0.0.1:2000](http://127.0.0.1:2000) (a browser running in the containers network)
    - Simulation GUI should be open in this browser: [http://gui:3001](http://gui:3001)
- RDF server: [http://localhost:4000](http://localhost:4000)

## MAS using WoT

The directory `wot` run a JaCaMo application with agent Alice that reads and acts on the plant based on discovering the plant from TDs.

To run:

```
cd wot
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