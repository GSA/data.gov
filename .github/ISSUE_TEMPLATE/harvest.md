---
name: Harvest Source Error
about: A ticket tracking harvest source errors
title: "Harvest Source Error: <source name>"
---
## Harvest Source Info


**Source Name:** 
**Source Type:** 
**Harvest Frequency:** 
**Last Successful Harvest:** 
**Last Update:** 
**Source URL:** 
**About Page:** 


### Error Info

_Paste in the error info from harvest report_


### Debugging

_Run the following command on your local and/or cloud.gov to tell if the source server side blocks our agent (`HarvesterBot`) or cloud.gov IPs (`52.222.122.97` and `52.222.123.172`)_

```
curl -I -L -A "HarvesterBot/0.0 (https://data.gov;datagovhelp@gsa.gov) Data.gov/2.0" [source_url]
```

