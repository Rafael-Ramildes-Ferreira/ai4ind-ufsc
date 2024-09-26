# AI4Industry @ UFSC

This repository contains auxiliary material for the Final Project of the [MultiAgent course](https://jomifred.github.io/mas/) of [Prof. Jomi Hubner](https://jomifred.github.io). The project description is [here](https://docs.google.com/document/d/1W6TgXikrYhW47doUN8UX8MfEgXsF8KFMu-lcJAeMM9Q/edit?usp=sharing).


To run the containers (simulator, GUI, NodeRed):

```
docker compose up
```

- Simulator: http://localhost:8080/storageRack
- GUI: http://localhost:3001
- NodeRed: http://127.0.0.1:1880


## How to build the images
Note that the required images can be obtained from DockerHub. What follow is used to publish the images there.

```
cd ~/tmp
git clone https://gitlab.emse.fr/ai4industry/ai4industry simul

cd simul/use-case
docker build --tag=jomifred/ai4ind-simu . 
docker image push jomifred/ai4ind-simu

cd ../gui

curl -LO https://raw.githubusercontent.com/jomifred/ai4ind-ufsc/refs/heads/main/docker-files/gui/Dockerfile
docker build --tag=jomifred/ai4ind-gui . 
docker image push jomifred/ai4ind-gui
```

Build the NodeRed with WebOfThings:

```
cd ai4ind-ufsc/docker-files/nodered
docker build --tag=jomifred/ai4ind-nodered . 
docker image push jomifred/ai4ind-nodered
```

