# Meine Stadt Transparent

Kubernetes deployment for [https://github.com/meine-stadt-transparent/meine-stadt-transparent](https://github.com/meine-stadt-transparent/meine-stadt-transparent)

## Todo

- Figure out why elasticsearch uses admin:admin
- See if Ingress can be used instead of the nginx container for routing

## Instructions

- Use the `secrets/*.env-example` files to create service secrets in the `secrets` folder. Fill your newly created files with random strings
- Install [`certstrap`](https://github.com/square/certstrap/releases/tag/v1.2.0)
- Generate certificates for elasticsearch with the script `make-elasticsearch-certs.sh`

Then:

```bash
kustomize build . | kubectl -n meine-stadt-transparent apply -f -
```

## Image pull secret

```
kubectl -n meine-stadt-transparent create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

## Initial scrape

```
kubectl -n meine-stadt-transparent create job initial-scrape --from=cronjob/sessionnet-scraper
```

## Map shows Japan

Find your Gemeindeschlüssel

```
kubectl -n meine-stadt-transparent exec deployments/meine-stadt-transparent .venv/bin/python manage.py import_outline 1 --ags <gemeindeschlüssel>
kubectl -n meine-stadt-transparent exec deployments/meine-stadt-transparent .venv/bin/python manage.py import_streets 1 --ags <gemeindeschlüssel>
```
