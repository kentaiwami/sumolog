from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///sumolog.db'
db = SQLAlchemy(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    uuid = db.Column(db.String(256), unique=True)

    def __init__(self, uuid):
        self.uuid = uuid

    def to_dict(self):
        return dict(uuid=self.uuid)


def db_create():
    db.create_all()


@app.route('/')
def hello_world():
    return 'Hello World!'


@app.route("/api/v1/user", methods=['POST'])
def api_v1_models():
    if request.method == 'POST':
        uuid = request.json['uuid']
        d = User(uuid)
        db.session.add(d)
        db.session.commit()
        return jsonify(d.to_dict()), 200


if __name__ == '__main__':
    db_create()
    app.run(host='0.0.0.0', port=80, debug=True)
