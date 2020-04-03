================
OpenStack RefApp
================

Minimal reference web app to validate clouds

why
===

Need a reference application which is:
- as minimal as possible re consumed resources
- touches as much of cloud services while created or used
- can be used in validation of user workloads surviving cloud LCM operations
  (update, upgrade)
- allows for automation (has an API to work with from tests/scripts)

what
====

Will consist of database backend (single node for now), actual data on Cinder
volume, multiple frontends with simple rest api behind Octavia
load balancer, possibly with custom TLS cert thru Barbican and domain name
via Designate.
Implemented as Heat template(s).
