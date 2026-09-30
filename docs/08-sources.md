# Sources and design decisions

Official sources were checked on **2026-09-30**. Upstream branches, image tags and interfaces can change. Record the versions you actually install. The supplied user brief provided the original learning sequence; this repository adapts it for an isolated SafeLine comparison rather than reproducing its older commands verbatim.

| Source | Used for |
|---|---|
| [SafeLine repository](https://github.com/chaitin/SafeLine) | Product purpose and upstream ownership |
| [SafeLine installer](https://github.com/chaitin/SafeLine/blob/main/scripts/manage.py) | Linux/CPU prechecks, installer options, default path and initial admin command |
| [SafeLine Compose](https://github.com/chaitin/SafeLine/blob/main/compose.yaml) | Host networking for tengine, management port and log mounts |
| [SafeLine deployment guide](https://docs.waf.chaitin.com/en/GetStarted/Deploy) | User reference for current installation UI/procedure |
| [SafeLine add-application guide](https://docs.waf.chaitin.com/en/GetStarted/AddApplication) | User reference for current site-management interface |
| [DVWA README](https://github.com/digininja/DVWA/blob/master/README.md) | Training use, setup and credentials |
| [DVWA Compose](https://github.com/digininja/DVWA/blob/master/compose.yml) | Official image and database starting point |
| [DVWA Dockerfile](https://github.com/digininja/DVWA/blob/master/Dockerfile) | Application web-root placement |
| [DVWA configuration](https://github.com/digininja/DVWA/blob/master/config/config.inc.php.dist) | Supported DB/security/auth environment settings |
| [DVWA build workflow](https://github.com/digininja/DVWA/blob/master/.github/workflows/docker-image.yml) | Published platform builds |
| [Docker Ubuntu installation](https://docs.docker.com/engine/install/ubuntu/) | Engine and Compose installation |
| [Docker port publishing](https://docs.docker.com/engine/network/port-publishing/) | Loopback binding, older-version caveat |
| [Docker host networking](https://docs.docker.com/engine/network/drivers/host/) | Interpretation of SafeLine's upstream reachability |
| [MariaDB health checks](https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/docker-and-mariadb/using-healthcheck-sh) | Database readiness helper |
| [Burp installation](https://portswigger.net/burp/documentation/desktop/getting-started/download-and-install) | Community installation |
| [Burp browser/interception](https://portswigger.net/burp/documentation/desktop/getting-started/intercepting-http-traffic) | Proxy workflow |
| [Burp scope](https://portswigger.net/burp/documentation/desktop/getting-started/setting-target-scope) | Restricting target history/workflow |
| [Burp Repeater](https://portswigger.net/burp/documentation/desktop/getting-started/reissuing-http-requests) | Manual replay |
| [GitHub existing-code upload](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github) | Repository publication |

SafeLine documentation pages did not expose readable content to the research tool. Installer and networking facts were checked against official source code; exact dashboard labels are therefore described as version dependent. Current ARM edition/license availability was not established. The guide does not promise any paid/optional feature is available in every edition.

The example IP addresses, memory allocations, port choices, evidence numbering, generated credentials and comparison method are this lab's design decisions. The loopback upstream is a reasoned application of host networking and must be verified on the installed release. No upstream source guarantees that a particular payload will be blocked; the tests measure actual behavior.
