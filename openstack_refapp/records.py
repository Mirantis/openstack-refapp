import logging

import falcon

from .models import Record

LOG = logging.getLogger(__name__)


class RecordResourceCollection:
    def on_get(self, req, resp):
        LOG.debug("Listing Records ...")
        result = req.context.session.query(Record).all()
        LOG.info(f"Got {len(list(result))} Records")
        resp.media = dict(records=list(r.to_dict() for r in result))

    def on_post(self, req, resp):
        LOG.debug("Creating Record ...")
        rec = req.media.get("record")
        if rec is None:
            resp.status = falcon.HTTP_400
            msg = "no 'record' object found in request"
            resp.media = {"message": msg}
            LOG.info(f"{msg}, rejecting")
            return
        data = rec.get("data")
        if data is not None:
            if not (isinstance(data, str) and len(data) < 256):
                resp.status = falcon.HTTP_400
                msg = (
                    "record.data is not a string or is too large "
                    "(limit is 255)"
                )
                resp.media = {"message": msg}
                LOG.info(f"{msg}, rejecting")
                return
        new_rec = Record(data=rec.get("data"))
        req.context.session.add(new_rec)
        LOG.debug("Committing Record ...")
        req.context.session.commit()
        LOG.info(f"Created record {new_rec.id} with data {new_rec.data}")
        resp.media = new_rec.to_dict()


class RecordResource:
    def on_get(self, req, resp, id):
        LOG.debug(f"Accessing Record {id} ...")
        result = req.context.session.query(Record).get(id)
        if result:
            resp.media = result.to_dict()
        else:
            LOG.info(f"No Record with id {id} found")
            resp.status = falcon.HTTP_404

    def on_delete(self, req, resp, id):
        LOG.debug("Deleting Record ...")
        result = (
            req.context.session.query(Record).filter(Record.id == id).delete()
        )
        if result:
            req.context.session.commit()
            LOG.debug("Record %s deleted", id)
        else:
            LOG.info(f"No Record with id {id} found")
            resp.status = falcon.HTTP_404
