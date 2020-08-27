import logging

from sqlalchemy import create_engine
from sqlalchemy.pool import NullPool
import falcon
import falcon_sqla

from . import conf
from . import models
from . import records
from . import root

db_engine = create_engine(conf.DB_URL, poolclass=NullPool)
models.init(db_engine)
sa_manager = falcon_sqla.Manager(db_engine)

logging.basicConfig(
    level=logging.DEBUG if conf.DEBUG else logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s:%(lineno)d -> %(message)s",
)


def create_app():
    app = falcon.API(
        middleware=[sa_manager.middleware],
    )
    app.add_route("/", root.RootResource())
    app.add_route("/records", records.RecordResourceCollection())
    app.add_route("/records/{id}", records.RecordResource())
    return app
