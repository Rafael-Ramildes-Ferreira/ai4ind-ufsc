# AI4Industry @ UFSC

To run the containers (simulator, GUI, NodeRed):

```
docker compose up
```


## How to build the images

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

