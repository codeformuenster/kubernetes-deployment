# Digitrans

see:
- https://digitransit.fi/en/
- https://github.com/verschwoerhaus/digitransit-kubernetes
- https://digitransit.fi/en/services/

- https://github.com/HSLdevcom/digitransit-kubernetes-deploy/blob/master/roles/aks-apply/files/prod/graphiql-prod.yml

```bash
kubectl create namespace digitransit
kustomize build . | kubectl apply -f -
```


## Docker images:

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


## GTFS import
https://github.com/verschwoerhaus/OpenTripPlanner-data-container/tree/hulm

https://www.stadtwerke-muenster.de/privatkunden/mobilitaet/fahrplaninfos/fahr-netzplaene-downloads/open-data-gtfs/gtfs-download.html
https://www.stadtwerke-muenster.de/fileadmin/stwms/busverkehr/kundencenter/dokumente/GTFS/stadtwerke_feed_20191028.zip

dos2unix?

https://download.geofabrik.de/europe/germany/nordrhein-westfalen/muenster-regbez.html
https://download.geofabrik.de/europe/germany/nordrhein-westfalen/muenster-regbez-latest.osm.pbf

ROUTERS=cfm ORG=codeformuester node index.js once

```bash
docker build -t local/otp-data .
docker run -ti local/otp-data bash



```

## Problems

Still requests to:
  https://api.digitransit.im.verschwoerhaus.de/map/v1/stop-map/12/2161/1416.pbf


---



cp $HOME/Downloads/muenster-regbez-latest.osm.pbf ./data/downloads/osm/muenster-regbez.pbf
cp $HOME/Downloads/stadtwerke_feed_20191028.zip ./data/downloads/gtfs/STWMS.zip

export graphBuildTag="latest"

export config_id="cfm"
export config_osm="muenster-regbez"

docker run --rm --entrypoint /bin/bash \
  -v $PWD/data/build:/opt/opentripplanner/graphs \
  hsldevcom/opentripplanner:$graphBuildTag \
    -c "java -Xmx10g -jar otp-shaded.jar --build graphs/$config_id/router"

> Graph building took 3.6 minutes.


# zipFile, glob, zipDir
zipWithGlob(
  `${dataDir}/build/${config.id}/router-${config.id}.zip`,
  [
    `${dataDir}/build/${config.id}/router/*.zip`,
    `${dataDir}/build/${config.id}/router/*.json`,
    `${dataDir}/build/${config.id}/router/${config.osm}.pbf`,
    `${dataDir}/build/${config.id}/router/${config.dem}.tif`
  ],
  `router-${config.id}`
)


```bash
export config_id="cfm"
# export config_osm="muenster-regbez"

sudo chown -R $USER:$USER .

# create zip file for the source data
# include all gtfs + osm + router- + build configs

mkdir -p "./temp/router-$config_id"

cp --target-directory="./temp/router-$config_id" \
  ./data/build/$config_id/router/*.zip \
  ./data/build/$config_id/router/*.json \
  ./data/build/$config_id/router/$config_osm.pbf

cd ./temp
zip "router-$config_id" -r "router-$config_id"
cd ..

mv ./temp/router-$config_id.zip ./data/build/$config_id/
rm ./temp -r


# create zip file for the graph:
# include  graph.obj + router-config.json

# zipFile, glob, zipDir
zipWithGlob(`${dataDir}/build/${config.id}/graph-${config.id}-${commit}.zip`,
  [`${dataDir}/build/${config.id}/router/Graph.obj`, 
  `${dataDir}/build/${config.id}/router/router-*.json`],
  config.id,


mkdir -p "./temp/$config_id"

cp --target-directory="./temp/$config_id" \
  ./data/build/$config_id/router/Graph.obj \
  ./data/build/$config_id/router/router-*.json

cd ./temp
zip "$config_id" -r "$config_id"
cd ..

export commit=$(docker run --rm --entrypoint /bin/bash \
  hsldevcom/opentripplanner:$graphBuildTag \
    -c "java -jar otp-shaded.jar --version" | sed -n 's/commit: //gp')

echo $commit

mv ./temp/$config_id.zip "./data/build/$config_id/graph-$config_id-$commit.zip"
rm ./temp -r


date --iso-8601=s --utc > ./data/build/$config_id/version.txt


ls ./data/build/$config_id -l



# otpMatching(`${dataDir}/build/${config.id}/router`, config.id)

export digitransit_urlprefix="https://digitransit.codeformuenster.org/"
curl "$digitransit_urlprefix"routing/v1/routers/cfm/index/graphql

https://digitransit.codeformuenster.org/routing/v1/routers/cfm/index/graphql



// process.stdout.write('Executing deploy script.\n')
// execFileSync('./deploy.sh', [router],
//   {
//     env: Object.assign({}, process.env,
//       {
//         TEST_TAG: process.env.OTP_TAG || '',
//         TOOLS_TAG: process.env.TOOLS_TAG || '',
//       }),
//     stdio: [0, 1, 2]
//   }
// )






```

!! check content of vsh image for comparison

docker run -ti verschwoerhaus/opentripplanner-data-container-vsh:2019-10-28-latest ls /var/www/localhost/htdocs/ -lh
-rw-rw-r--    1 root     root      494.0K Oct 29 01:32 build.log
-rw-rw-r--    1 root     root          70 Oct 29 01:33 connected.csv
-rw-rw-r--    1 root     root      135.0M Oct 29 01:33 graph-vsh-a0c7971f62251a3a1070652a3895c628557e1b62.zip
-rw-rw-r--    1 root     root      203.0M Oct 29 01:33 router-vsh.zip
-rw-rw-r--    1 root     root         140 Oct 29 01:25 test.sh
-rw-rw-r--    1 root     root          39 Oct 29 01:33 unconnected.csv
-rw-rw-r--    1 root     root          24 Oct 29 01:32 version.txt

https://github.com/HSLdevcom/OpenTripPlanner/blob/master/Dockerfile
https://github.com/HSLdevcom/OpenTripPlanner/blob/master/run.sh

  ROUTER_DATA_CONTAINER_URLS
  ROUTER_NAMES

  ROUTERS=$(printf " --router %s" ${ROUTER_NAMES[@]})

  url() "${ROUTER_DATA_CONTAINER_URLS[$1]}"/$2
  version() java -jar $JAR --version|grep commit|cut -d' ' -f2

  download_graph()
    GRAPH_FILE=graph-$NAME.zip
    unzip $GRAPH_FILE  -d ./graphs

  process()
    GRAPHNAME=$1
    ROUTER_DATA_CONTAINER_URL=$2  # ROUTER_DATA_CONTAINER_URLS[$j]

    curl -f -s -o "$GRAPHNAME.zip" \
      "$ROUTER_DATA_CONTAINER_URL/router-$GRAPHNAME.zip"

    rm -rf graphs/$GRAPHNAME || true
    mkdir -p graphs

    unzip -o -d graphs "$GRAPHNAME.zip"
    mv graphs/router-$GRAPHNAME graphs/$GRAPHNAME

    JAR=`ls *-shaded*`
    java $JAVA_OPTS -jar $JAR --build graphs/$GRAPHNAME


  for ROUTER in "${ROUTER_NAMES[@]}"
  do
    download_graph $ROUTER $VERSION "$j" || process $ROUTER "$j"
    j=$[$j+1]
  done


  java \
    -Dsentry.release=$VERSION \
    $JAVA_OPTS \
    -Duser.timezone=Europe/Helsinki \
    -jar $JAR \
    --server \
    --port $PORT \
    --securePort $SECURE_PORT \
    --basePath ./ \
    --graphs ./graphs \
    $ROUTERS

---


kubectl -n digitransit exec -ti opentripplanner-67fc7d954d-z7lfq -- ls /opt/opentripplanner/graphs/vsh -lh
-rw-r--r--    1 root     root      332.6M Nov  9 20:37 Graph.obj
-rw-r--r--    1 root     root         498 Nov  9 20:37 router-config.json


kubectl -n digitransit exec -ti opentripplanner-67fc7d954d-z7lfq -- cat /opt/opentripplanner/graphs/vsh/router-config.json
{
  "routingDefaults": {
    "walkSpeed": 1.3,
    "transferSlack": 120,
    "maxTransfers": 4,
    "waitReluctance": 0.95,
    "waitAtBeginningFactor": 0.7,
    "walkReluctance": 1.75,
    "stairsReluctance": 1.65,
    "walkBoardCost": 540,
    "itineraryFiltering": 1
  },
  "updaters": [
    {
      "id": "openbike-bike-rental",
      "type": "bike-rental",
      "sourceType": "gbfs",
      "url": "https://api.dev.bike/gbfs/",
      "frequencySec": 10,
      "network": "openbike"
    }
  ]
}




---


/home/webwurst/.kube/config.d/codeformuenster-admin.config ~/D/g/c/k/s/digitransit> kubectl -n digitransit logs -f -l app=opentripplanner
03:59:17.220 WARN (Dsn.java:89) *** Couldn't find a suitable DSN, Sentry operations will do nothing! See documentation: https://docs.sentry.io/clients/java/ ***
03:59:17.244 WARN (DefaultSentryClientFactory.java:524) No 'stacktrace.app.packages' was configured, this option is highly recommended as it affects stacktrace grouping and display on Sentry. See documentation: https://docs.sentry.io/clients/java/config/#in-application-stack-frames
03:59:17.251 WARN (InputStreamGraphSource.java:118) Unable to load data for router 'cfm'.
03:59:17.251 WARN (GraphService.java:185) Can't register router ID 'cfm', no graph.
03:59:17.262 INFO (GrizzlyServer.java:72) Starting OTP Grizzly server on ports 8080 (HTTP) and 8081 (HTTPS) of interface 0.0.0.0
03:59:17.263 INFO (GrizzlyServer.java:74) OTP server base path is ./
03:59:17.342 INFO (GrizzlyServer.java:51) Java reports that this machine has 1 available processors.
03:59:17.343 INFO (GrizzlyServer.java:62) Maximum HTTP handler thread pool size will be 4 threads.
2019-11-13T03:59:22.960+0100  WARNING  There is no way how to transform value "true" [java.lang.Boolean] to type [java.lang.String].
03:59:23.133 INFO (GrizzlyServer.java:154) Grizzly server running.



---

exec

./sass/themes/cfm/_theme.scss
./sass/themes/cfm/main.scss
./app/configurations/config.cfm.js
./app/configurations/config.default.js

root@digitransit-7bb9df4db-2n8hv:~# ls ./sass/themes/hsl/ -l
total 20
-rw-rw-r-- 1 root root  466 Nov 14 14:31 _icon.scss
-rw-rw-r-- 1 root root 1307 Nov 14 14:31 _theme.scss
-rw-rw-r-- 1 root root 1790 Nov 14 14:31 hsl-spinner.png
-rw-rw-r-- 1 root root 3453 Nov 14 14:31 icon_favicon-reittiopas.svg
-rw-rw-r-- 1 root root   69 Nov 14 14:31 main.scss


---

const imageDir = 'app/configurations/images/' + theme;