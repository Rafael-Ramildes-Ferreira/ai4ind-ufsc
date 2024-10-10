# AI4Industry @ UFSC

This repository contains auxiliary material for the Final Project of the [MultiAgent course](https://jomifred.github.io/mas/) of [Prof. Jomi Hubner](https://jomifred.github.io). The project description is [here](https://docs.google.com/document/d/1W6TgXikrYhW47doUN8UX8MfEgXsF8KFMu-lcJAeMM9Q/edit?usp=sharing).


To run the containers (simulator, GUI, NodeRed):

```
docker compose up
```

- Simulator: [http://localhost:8080/storageRack](http://localhost:8080/storageRack)
- NodeRed: [http://127.0.0.1:1880](http://127.0.0.1:1880)
- Browser: [http://127.0.0.1:2000](http://127.0.0.1:2000)
    - GUI should be open in the above browser: [http://gui:3001](http://gui:3001)
- RRF server: [http://localhost:4000](http://localhost:4000)

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

