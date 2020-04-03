import datetime
import platform

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DateTime

Base = declarative_base()


class Record(Base):
    __tablename__ = "records"
    id = Column(Integer, primary_key=True, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    data = Column(String(255), nullable=True)
    host = Column(String(255), nullable=False, default=platform.node())

    def to_dict(self):
        return {
            "record": dict(
                id=self.id,
                created_at=self.created_at.isoformat(timespec="milliseconds"),
                host=self.host,
                data=self.data,
            )
        }


def init(engine):
    Base.metadata.create_all(engine)
