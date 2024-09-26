# docker build --tag=ai4ind-gui . 
# docker run -p 3001:3001 ai4ind-gui

FROM node:lts-alpine

MAINTAINER Jomi Hubner

ENV GUI /gui

RUN mkdir $GUI
COPY package.json $GUI
COPY public/* $GUI/public/
COPY src/* $GUI/src/

WORKDIR $GUI
RUN npm install --legacy-peer-deps

EXPOSE 3001

CMD ["npm", "start"]
