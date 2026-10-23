# Egress proxy lists

`bin/enable-egress` (run by the "enable egress proxy" workflow) deploys a
[cg-egress-proxy](https://github.com/GSA-TTS/cg-egress-proxy) for an app into
`<space>-egress` and configures it with an allow list and a deny list from
`acl/`. The files contain one entry per line (a hostname, `*.` wildcard, IP,
CIDR range, or `all`) and can't contain comments.

- `acl/<space>.allow.acl` and `acl/<space>.deny.acl` are the shared lists, used
  by any app without its own.
- `acl/<app>.<space>.allow.acl` and `acl/<app>.<space>.deny.acl`, when
  present, are used for that app in that space instead.

A list can't be empty, so a deny list with nothing to deny holds the
placeholder `somewebsitesothisisntempty.com`.

## datagov-harvest-validator

The public DCAT-US validator (`harvest.data.gov/api/v1/validate`) fetches
catalogs from any publisher, including ones not yet registered as harvest
sources, so its proxy allows all hosts (`all`) and denies nothing. The rest is
outside the lists:
- The proxy's default `PROXY_PORTS` of 443 means it only allows HTTPS.
- The egress space's security groups don't include private networks, so the
  proxy can't reach internal addresses.
- The validator refuses private addresses itself before asking the proxy; see
  `docs/validator-security.md` in GSA/datagov-harvester.
