# event-scraper-flow-test2

```bash
kustomize build . | kubectl apply -f -
```

```bash
curl --request POST https://workflow.codeformuenster.org/testing1
# request successfully processed⏎

curl --request POST https://workflow.codeformuenster.org/events-v0 \
  --header "Content-Type: application/json" \
  --data '{"message":"[events-v0] this is my second webhook -- 123"}'
# request successfully processed⏎

curl --request POST https://workflow.codeformuenster.org/example \
  --header "Content-Type: application/json" \
  --data '{"message":"[test] this is my second webhook -- 123"}'
# request successfully processed⏎
```

See: https://workflow.codeformuenster.org/workflows
