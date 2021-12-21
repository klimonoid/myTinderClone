from peewee import *

database = PostgresqlDatabase('tinder', **{'host': 'localhost', 'password': 'Limelime100'})


class BaseModel(Model):
    class Meta:
        database = database


class Question(BaseModel):
    text = CharField()

    class Meta:
        table_name = 'question'


class Answer(BaseModel):
    question = ForeignKeyField(column_name='question_id', field='id', model=Question)
    text = CharField()

    class Meta:
        table_name = 'answer'


class Anthem(BaseModel):
    link = CharField()

    class Meta:
        table_name = 'anthem'


class User(BaseModel):
    about = CharField()
    age = IntegerField()
    amount_of_boosts = IntegerField(null=True)
    amount_of_likes = IntegerField(null=True)
    amount_of_rewinds = IntegerField(null=True)
    amount_of_super_likes = IntegerField(null=True)
    anthem = ForeignKeyField(column_name='anthem_id', field='id', model=Anthem, null=True)
    boost_start_time = TimeField(null=True)
    email = CharField()
    frozen = BooleanField()
    gender = CharField()
    level = CharField()
    looking_for = CharField()
    name = CharField()
    online = BooleanField()
    password = CharField()
    phone = CharField()
    position_attitude = DoubleField()
    position_longitude = DoubleField()
    region_attitude = DoubleField(null=True)
    region_longitude = DoubleField(null=True)

    class Meta:
        table_name = 'user'


class Block(BaseModel):
    blocked_user = ForeignKeyField(column_name='blocked_user', field='id', model=User)
    blocker_user = ForeignKeyField(backref='user_blocker_user_set', column_name='blocker_user', field='id', model=User)

    class Meta:
        table_name = 'block'


class Match(BaseModel):
    first_user = ForeignKeyField(column_name='first_user', field='id', model=User)
    second_user = ForeignKeyField(backref='user_second_user_set', column_name='second_user', field='id', model=User)

    class Meta:
        table_name = 'match'


class Message(BaseModel):
    from_user = ForeignKeyField(column_name='from_user', field='id', model=User)
    read = BooleanField()
    text = CharField()
    to_user = ForeignKeyField(backref='user_to_user_set', column_name='to_user', field='id', model=User)

    class Meta:
        table_name = 'message'


class Photo(BaseModel):
    photo_path = CharField()
    user = ForeignKeyField(column_name='user_id', field='id', model=User)

    class Meta:
        table_name = 'photo'


class Rejection(BaseModel):
    date = DateTimeField()
    from_user = ForeignKeyField(column_name='from_user', field='id', model=User)
    to_user = ForeignKeyField(backref='user_to_user_set', column_name='to_user', field='id', model=User)

    class Meta:
        table_name = 'rejection'


class Sympathy(BaseModel):
    date = DateTimeField()
    from_user = ForeignKeyField(column_name='from_user', field='id', model=User)
    status = CharField()
    to_user = ForeignKeyField(backref='user_to_user_set', column_name='to_user', field='id', model=User)
    type = CharField()

    class Meta:
        table_name = 'sympathy'


class Vibe(BaseModel):
    answer = ForeignKeyField(column_name='answer_id', field='id', model=Answer)
    question = ForeignKeyField(column_name='question_id', field='id', model=Question)

    class Meta:
        table_name = 'vibe'


class VibeToClient(BaseModel):
    user = ForeignKeyField(column_name='user_id', field='id', model=User)
    vibe = ForeignKeyField(column_name='vibe_id', field='id', model=Vibe)

    class Meta:
        table_name = 'vibe_to_client'
