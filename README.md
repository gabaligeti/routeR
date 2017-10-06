---
title: "How to use router"
output: github_document
---

## Install and configure rApache

link!!!

## Using router

Web API with GET method, one endpoint and summing up two variables:

```
library(router)

r <- router()
r <- add_route(r, 
    method = "GET",
    endpoint = "/add/",
    fun = function(a, b) {
        return(as.numeric(a) + as.numeric(b))
    }
)

run(r)
```

Saving the code in a file such as `/var/www/simpleapi.com/app.R`, the corresponding apache config file for this service looks like:

```
Listen 81

<VirtualHost *:81>

        ServerName simpleapi

        ServerAdmin me@simpleapi
        DocumentRoot /var/www/simpleapi

        ErrorLog ${APACHE_LOG_DIR}/simpleapi/error.log

        <Location />
                SetHandler r-handler
                RFileHandler app.R
                REvalOnStartup "library(router)"
        </Location>
</VirtualHost>
```
