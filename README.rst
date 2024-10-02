================
OpenStack RefApp
================

Minimal reference web app to validate clouds

why
===

Need a reference application which is:
- as minimal as possible re consumed resources
- involves many cloud services while created or used
- can be used in validation of user workloads surviving cloud LCM operations
  (update, upgrade)
- allows for automation (has an API to work with from tests/scripts)

what
====

Current version consists of:

- **Neutron** networks, subnets, routers and floating IPs for servers
- 3 **Nova** instances running MySQL Galera cluster as Database

  - Database files are kept on a separately attached **Cinder** volumes

- 3 **Nova** instances running this app as API
- **Octavia** load balancer for Database instances
- **Octavia** load balancer for API instances
- DNS zones and records created for the instances in **Designate**

**Keystone** and **Glance** are involved implicitly.

Implemented two deployment scenarios:

- as OpenStack Orchestration (**Heat**) template(s)
- as Terraform/OpenTofu configuration

todo
----

- involve **Barbican** into the mix by using TLS-terminating
  Octavia load balancer with user-supplied certificate.

API ref
=======

Record object in YAML notation::

    record:
      id: <int>         # auto, ID of the record
      created_at: <str> # auto, timestamp of the record creation
      host: <str>       # auto, hostname of the api that made the record
      data: <str>       # optional, payload of the record, 255 chars max


GET /
-----

Returns node identifier::

    {
      "host": "host name of API instance that replied",
      "app": "openstack-refapp"
    }


POST /records
-------------

Create record object in DB::

    $ curl http://<host:port>/records -X POST -H "Content-Type: application/json" --data '{"record": {"data": "spam"}}'
    {"record": {"id": 3, "created_at": "2020-04-06T12:13:47.000", "host": "f1f66c9fb4b3", "data": "spam"}}

``data`` field is optional, but the ``record`` object is not.
Example with ``httpie`` CLI client and no data::

    $ http <host:port>/records record:='{}'
    HTTP/1.1 200 OK
    Connection: close
    Date: Mon, 06 Apr 2020 12:17:12 GMT
    Server: gunicorn/20.0.4
    content-length: 100
    content-type: application/json

    {
        "record": {
            "created_at": "2020-04-06T12:17:12.000",
            "data": null,
            "host": "f1f66c9fb4b3",
            "id": 4
        }
    }

GET /records
------------

List records pulled from DB (no pagination for now)::

    {
        "records": [
            {
                "record": {
                    "created_at": "2020-04-06T08:38:16.000",
                    "data": null,
                    "host": "3c1cb4f4d7f0",
                    "id": 1
                }
            },
            {
                "record": {
                    "created_at": "2020-04-06T12:12:52.000",
                    "data": null,
                    "host": "f1f66c9fb4b3",
                    "id": 2
                }
            }
         ]
    }


GET /records/{id}
-----------------

Show record by its id::

    $ curl http://<host:port>/records/2
    {"record": {"id": 2, "created_at": "2020-04-06T12:12:52.000", "host": "f1f66c9fb4b3", "data": null}}

DELETE /records/{id}
--------------------

Delete single record by its id::

    $ curl -X DELETE http://<host:port>/records/2

DELETE /records
---------------

Delete all records in one go, cleanup the database::

    $ curl -X DELETE http://<host:port>/records


Used external components
========================

`wait-for` script used in docker compose setup
courtesy of https://github.com/Eficode/wait-for (MIT License)
