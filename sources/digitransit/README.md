# digitrans

see:
- https://digitransit.fi/en/
- https://github.com/verschwoerhaus/digitransit-kubernetes


```bash
kubectl create namespace digitrans
kustomize build . | kubectl apply -f -
```



## Docker images:

**digitransit-proxy-vsh**
https://hub.docker.com/r/verschwoerhaus/digitransit-proxy-vsh
https://github.com/verschwoerhaus/digitransit-proxy/blob/vsh/Dockerfile

https://github.com/HSLdevcom/digitransit-proxy/compare/master...verschwoerhaus:vsh

```conf
common.conf
  location /geocoding/v1/ {
    proxy_pass         http://photon-pelias-adapter:8080/;

  location /routing/v1/routers/vsh {
    proxy_pass         http://opentripplanner-vsh:8080/;

  location /routing-data/v2/vsh {
    proxy_pass         http://opentripplanner-data-con-vsh:8080/;
    include            cors.conf;
      ; add_header 'Access-Control-Allow-Origin' '*';
      ; add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
      ; add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';

  location /ui/v1/vsh/ {
    proxy_pass         http://digitransit-ui-vsh:8080;

  location /map/v1/ {
    proxy_pass         http://hsl-map-server:8080;
    proxy_cache        tiles; 
    ; what?

  location /graphiql/ {
    proxy_pass         http://graphiql:8080;
```

```conf
external.conf
  # swu gtfs: http://gtfs.swu.de/daten/SWU.zip
  location /out/gtfs.swu.de/ {
    proxy_pass    http://gtfs.swu.de;
    ; what?
```

```conf
nginx.conf
  http {
    server {
      server_name   api.digitransit.im.verschwoerhaus.de
                    "";

    server {
      server_name digitransit.im.verschwoerhaus.de;

      location = /sw.js {
        proxy_pass         http://digitransit-ui-vsh:8080;

      location / {
        proxy_pass         http://digitransit-ui-vsh:8080;

```

**digitransit-ui**
https://hub.docker.com/r/verschwoerhaus/digitransit-ui
https://github.com/verschwoerhaus/digitransit-ui/blob/ulm/Dockerfile

**graphiql**
https://hub.docker.com/r/verschwoerhaus/graphiql
https://github.com/HSLdevcom/graphiql-deployment/blob/master/Dockerfile

**hsl-map-server**
https://hub.docker.com/r/verschwoerhaus/hsl-map-server
https://github.com/verschwoerhaus/hsl-map-server/blob/ulm/Dockerfile

**opentripplanner-data-container-vsh**
https://hub.docker.com/r/verschwoerhaus/opentripplanner-data-container-vsh
https://github.com/verschwoerhaus/OpenTripPlanner-data-container/blob/ulm/Dockerfile

**opentripplanner**
https://hub.docker.com/r/hsldevcom/opentripplanner
https://github.com/HSLdevcom/OpenTripPlanner/blob/master/Dockerfile

**photon-pelias-adapter**
https://hub.docker.com/r/stadtulm/photon-pelias-adapter
https://github.com/stadtulm/photon-pelias-adapter


---


https://api.digitransit.codeformuenster.org/routing/v1/routers/vsh/index/graphql