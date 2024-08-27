# User Workload MOnitoring enabled

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
    alertmanagerMain:
      enableUserAlertmanagerConfig: true
```

# Namespace label

```yaml
openshift.io/cluster-monitoring: "false"
```


# Query monitoring API

TOKEN=$(oc whoami -t)

TOKEN=$(oc get secret -n grafana-community-instance grafana-community-instance-sa-token -o "jsonpath={.data.token}" | base64 --decode)

TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6IjZJWG5GdFJ4RkxIOGJ0ZlZUa0VMZ0oyUjBUMjZ6cVowZzRFdmdEN1VDWWcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJncmFmYW5hLWNvbW11bml0eS1pbnN0YW5jZSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJncmFmYW5hLWNvbW11bml0eS1pbnN0YW5jZS1zYS10b2tlbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJncmFmYW5hLWNvbW11bml0eS1pbnN0YW5jZS1zYSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjFhY2QzM2FiLTFiYWYtNDRmOS1hOWE2LWM4ZGEyNGI3NDNkZiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpncmFmYW5hLWNvbW11bml0eS1pbnN0YW5jZTpncmFmYW5hLWNvbW11bml0eS1pbnN0YW5jZS1zYSJ9.zhzarrwqr_ZeZXZralqItwe2WIIgf3mHCje1pIYXFIcaCJh7HakZpPMdCtgYBHAlc5nzZhL1gIgeFo6miKFxqIFBLdDd1J5xbfnKYZbWjSbcmc01iFRrws9vf7Vub1gIqChsQQgG9s5s5PG8GxM5Bw49BngDE4i_8jsLUQxWMJijpCpd2g5Yiet5lPKhdJYxKR9RLjaFFiIeCbjuFBwZEmF2ITog7RJHuu97U6QgK8O6ukMbfUWz2Dmg8oZEDgciU4nnkvf8NsIrspx2-ZMEfsEjZiy7xBP0tmT_7XJmrzrvfnCGNc0bOYlSgkHlEvCh0vhnl4p40mYUaY_lSVDqsjk82jy9aGfZhz9Rr6tDj4pyeuhL_kUc4L92qlsFuRHLhhMZcwLgB5H38_DI2a0ugOMvCP4cWk-pTt6ZWPgadDSweoEWatAinxbNVHYjoB-Z6bZlQuP2ulNgV1zDJooLqJA06Ri9j7ESfIfaot0uQSg1RuJyPemkoS0t0H74jMjXQeqCpOZpddXHUnIWEdPrJJq-GxheAS6Z2zMwskDTrp5kEnM4Hx_uvfWL7jCQA2P04W5jDhFB6TiuZXPt4XsV0EDM6Hc50QAJt2oWc_bOJ3sDcXJ8AkQuJ06OumDZpYKm_nPkdL6v95dTTAwXGKrMUlQ9SzdJ8hZdjNV568rxEck"

HOST=thanos-querier-openshift-monitoring.apps.cluster-nqjdt.nqjdt.sandbox280.opentlc.com

HOST="https://thanos-querier.openshift-monitoring.svc.cluster.local:9091/api/v1/query?"

NAMESPACE=grafana-community-instance

curl -H "Authorization: Bearer $TOKEN" -k "$HOST" --data-urlencode "query=up"



oc login --token=$TOKEN --server=https://api.cluster-nqjdt.nqjdt.sandbox280.opentlc.com:6443