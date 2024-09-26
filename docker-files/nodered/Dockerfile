# docker build --tag=ai4ind-nodered . 
# docker run -it -p 1880:1880 -v ./node_red_data:/data ai4ind-nodered

FROM nodered/node-red:4.0.3-22


RUN npm install node-red-dashboard
#RUN npm install @hidetak/node-red-contrib-web-of-things
RUN npm install @thingweb/node-red-node-wot

#RUN npm install serialport@9.2.8
#RUN npm install nan

CMD ["node-red"]
