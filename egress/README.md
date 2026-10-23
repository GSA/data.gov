# Egress proxy lists

`bin/enable-egress` (run by the "enable egress proxy" workflow) deploys a
[cg-egress-proxy](https://github.com/GSA-TTS/cg-egress-proxy) for an app into
`<space>-egress` and configures it with an allow list and a deny list from
`acl/`. The files contain one entry per line (a hostname, `*.` wildcard, IP,
CIDR range, or `all`) and can't contain comments.

- `acl/<space>.allow.acl` and `acl/<space>.deny.acl` are the shared lists, used
  by any app without its own.
- `acl/<app>.allow.acl` and `acl/<app>.deny.acl`, when present, are used for
  that app in every space instead.

## datagov-harvest-validator

The public DCAT-US validator (`harvest.data.gov/api/v1/validate`) fetches
catalogs from any publisher, including ones not yet registered as harvest
sources, so its proxy allows all hosts (`all`). It denies private, loopback,
link-local (cloud metadata) and shared address ranges instead. The proxy checks
those against every address a hostname resolves to, which also blocks DNS
names that point at internal addresses. The proxy's default `PROXY_PORTS` of
443 means it only allows HTTPS.

The validator also refuses private addresses itself before asking the proxy;
see `docs/validator-security.md` in GSA/datagov-harvester.
