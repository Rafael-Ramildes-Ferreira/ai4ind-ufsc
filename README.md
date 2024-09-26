# AI4Industry @ UFSC

To run the simulator:

```
docker network create ai4industry
docker run -p 8080:8080 --network=ai4industry jomifred/ai4ind-simu
```

To run the GUI:

```
docker run -p 3001:3001 --network=ai4industry jomifred/ai4ind-gui
```


## How to build the images

```
cd ~/tmp
git clone https://gitlab.emse.fr/ai4industry/ai4industry simul

cd simul/use-case
docker build --tag=jomifred/ai4ind-simu . 
docker image push jomifred/ai4ind-simu

cd ../gui

curl -LO https://jomifred.github.io/mas/ai4industry/simul/Dockerfile
docker build --tag=jomifred/ai4ind-gui . 
docker image push jomifred/ai4ind-gui
```

Build the NodeRed with WebOfThings:

```
cd ai4ind-ufsc/docker-files/nodered
docker build --tag=jomifred/ai4ind-nodered . 
docker image push jomifred/ai4ind-nodered
```

