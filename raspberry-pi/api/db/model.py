from sqlalchemy import Column, Integer, String
from db.database import Base


class WikiContent(Base):
    __tablename__ = 'sumolog'
    id = Column(Integer, primary_key=True)
    uuid = Column(String(256), unique=True)

    def __init__(cls, classname, bases, dict_, title=None, body=None, date=None):
        super().__init__(classname, bases, dict_)
        cls.title = title
        cls.body = body
        cls.date = date
