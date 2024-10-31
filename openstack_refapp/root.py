import logging
import platform

import falcon
import json

LOG = logging.getLogger(__name__)


class RootResource:
    def on_get(self, req, resp):
        LOG.info(f"got request {req}")
        resp.status = falcon.HTTP_200
        resp.text = json.dumps(
            dict(app="openstack-refapp", host=platform.node())
        )
