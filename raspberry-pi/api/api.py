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


@app.route('/api/v1/user', methods=['GET'])
def api_v1_get_user():
    if request.method == 'GET':
        users = User.query.all()

        return jsonify(dict(count=len(users))), 200


@app.route('/api/v1/user', methods=['POST'])
def api_v1_create_user():
    if request.method == 'POST':
        uuid = request.json['uuid']

        users = User.query.all()
        if len(users) == 0:
            d = User(uuid)
        else:
            d = users[0]
            d.uuid = uuid

        db.session.add(d)
        db.session.commit()

        return jsonify(d.to_dict()), 200


@app.route('/api/v1/user', methods=['DELETE'])
def api_v1_delete_user():
    if request.method == 'DELETE':
        User.query.delete()
        db.session.commit()
        return ''


if __name__ == '__main__':
    db_create()
    app.run(host='0.0.0.0', port=80, debug=True)
