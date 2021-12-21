import string
import random
import csv

from faker import Faker
from models import *

database = PostgresqlDatabase('tinder', **{'host': 'localhost', 'password': 'Limelime100'})
fake = Faker('ru_RU')


def fill_anthems(amount):
    for _ in range(amount):
        band_name = str(fake.word()).capitalize()

        track_name = str(fake.text(max_nb_chars=15))
        track_name = track_name[0: len(track_name) - 1].replace(' ', '-')

        link = "https://soundcloud.com/" + band_name + "/" + track_name
        Anthem.create(link=link)


def fill_vibes(path):
    with open(path, newline='') as file:
        reader = csv.reader(file)
        for row in reader:
            question = Question.create(text=row[0])
            answers = []
            answers.append(Answer.create(text=row[1], question=question))
            answers.append(Answer.create(text=row[2], question=question))
            if row[3] != "":
                answers.append(Answer.create(text=row[3], question=question))
            if row[4] != "":
                answers.append(Answer.create(text=row[4], question=question))
            for answer in answers:
                Vibe.create(question_id=question.get_id(), answer_id=answer.get_id())


def random_password(length):
    letters = string.ascii_letters + string.digits
    return ''.join(random.choice(letters) for _ in range(length))


def fill_users(amount):
    for i in range(amount):
        email = str(fake.email()).replace(' ', '')
        password = random_password(random.randint(15, 30))
        position_attitude = random.uniform(0.0, 90.0)
        position_longitude = random.uniform(0.0, 180.0)
        name = ''
        gender = ''
        if random.randint(0, 1) == 1:
            name = fake.first_name_female()
            gender = 'F'
        else:
            name = fake.first_name_male()
            gender = 'M'

        looking_for = ""
        if random.randint(0, 1) == 1:
            looking_for = 'F'
        else:
            looking_for = 'M'

        phone = fake.phone_number()
        age = random.randint(18, 60)
        about = fake.text(max_nb_chars=200)
        online = random.randint(0, 1)
        if online == 0:
            online = False
        else:
            online = True

        level = random.randint(0, 100)
        region_attitude = 0
        region_longitude = 0
        amount_of_boosts = 0
        amount_of_likes = 0
        amount_of_super_likes = 0
        amount_of_rewinds = 0
        boost_start_time = 0
        if 0 <= level < 65:
            level = 'regular'
            region_attitude = random.uniform(0.0, 90.0)
            region_longitude = random.uniform(0.0, 180.0)
            amount_of_boosts = 0
            amount_of_likes = 100
            amount_of_super_likes = 0
            amount_of_rewinds = 0
            boost_start_time = None
        elif 65 <= level < 85:
            level = 'plus'
            region_attitude = random.uniform(0.0, 90.0)
            region_longitude = random.uniform(0.0, 180.0)
            amount_of_boosts = 0
            amount_of_likes = None
            amount_of_super_likes = 0
            amount_of_rewinds = None
            boost_start_time = None
        elif 85 <= level <= 95:
            level = 'gold'
            region_attitude = random.uniform(0.0, 90.0)
            region_longitude = random.uniform(0.0, 180.0)
            amount_of_boosts = 1
            amount_of_likes = None
            amount_of_super_likes = 5
            amount_of_rewinds = None
            boost_start_time = None
        else:
            level = 'platinum'
            region_attitude = random.uniform(0.0, 90.0)
            region_longitude = random.uniform(0.0, 180.0)
            amount_of_boosts = 1
            amount_of_likes = None
            amount_of_super_likes = 5
            amount_of_rewinds = None
            boost_start_time = None
        frozen = random.randint(0, 10)
        if online == 0:
            frozen = False
        else:
            frozen = True

        anthem_id = None
        if random.randint(0, 100) > 40:
            anthem_id = Anthem.select().where(Anthem.id == random.randint(1, Anthem.select().count())).get().id

        User.create(
            email=email,
            password=password,
            region_attitude=region_attitude,
            region_longitude=region_longitude,
            phone=phone,
            name=name,
            age=age,
            about=about,
            gender=gender,
            looking_for=looking_for,
            position_attitude=position_attitude,
            position_longitude=position_longitude,
            online=online,
            level=level,
            amount_of_boosts=amount_of_boosts,
            amount_of_likes=amount_of_likes,
            amount_of_super_likes=amount_of_super_likes,
            amount_of_rewinds=amount_of_rewinds,
            boost_start_time=boost_start_time,
            frozen=frozen,
            anthem_id=anthem_id
        )


def fill_vibe_to_client():
    for user in User.select():
        if random.randint(0, 100) >= 60:
            for _ in range(random.randint(1, 5)):
                vibe = Vibe.select().where(Vibe.id == random.randint(1, Vibe.select().count())).get()
                VibeToClient.create(user=user.id, vibe=vibe.id)


def fill_photos(base):
    for user in User.select():
        for _ in range(random.randint(1, 6)):
            photo = Photo.create(photo_path=base + str(user.id) + '/', user=user.id)
            photo.photo_path += str(photo.id) + ".png"


def fill_sympathy():
    for from_user in User.select():
        for _ in range(random.randint(0, 20)):
            if random.randint(1, 100) <= 40:
                to_user = User.select().where(User.id == random.randint(1, User.select().count())).get()

                type_of_sympathy = "regular"
                if from_user.level != 'regular' and random.randint(1, 100) >= 60:
                    type_of_sympathy = 'super'
                rand = random.randint(1, 100)
                status = ''
                if rand <= 50:
                    status = 'unseen'
                    Sympathy.create(
                        date=fake.date_this_year(),
                        from_user=from_user.id,
                        to_user=to_user.id,
                        status=status,
                        type=type_of_sympathy
                    )

                elif 50 < rand < 95:
                    status = 'ignored'
                    sympathy = Sympathy.create(
                        date=fake.date_this_year(),
                        from_user=from_user.id,
                        to_user=to_user.id,
                        status=status,
                        type=type_of_sympathy
                    )

                    Rejection.create(
                        from_user=to_user,
                        to_user=from_user,
                        date=sympathy.date
                    )
                else:
                    Sympathy.create(
                        date=fake.date_this_year(),
                        from_user=from_user.id,
                        to_user=to_user.id,
                        status='match',
                        type=type_of_sympathy
                    )
                    Sympathy.create(
                        date=fake.date_this_year(),
                        from_user=to_user.id,
                        to_user=from_user.id,
                        status='match',
                        type='regular'
                    )
                    Match.create(
                        first_user=from_user.id,
                        second_user=to_user.id
                    )


def fill_messages():
    for match in Match.select():
        for _ in range(random.randint(1, 15)):
            Message.create(
                from_user=match.first_user,
                read=True,
                text=fake.text(max_nb_chars=40),
                to_user=match.second_user
            )
            Message.create(
                from_user=match.second_user,
                read=True,
                text=fake.text(max_nb_chars=40),
                to_user=match.first_user
            )
        if random.randint(1, 100) >= 70:
            if random.randint(0, 1) == 0:
                Block.create(
                    blocked_user=match.first_user,
                    blocker_user=match.second_user
                )
            else:
                Block.create(
                    blocked_user=match.second_user,
                    blocker_user=match.first_user
                )
        else:
            Message.create(
                from_user=match.first_user,
                read=True,
                text=fake.text(max_nb_chars=40),
                to_user=match.second_user
            )


if __name__ == '__main__':
    fill_anthems(100)
    fill_vibes('Вопросы.csv')
    fill_users(500)
    fill_vibe_to_client()
    fill_photos('/Users/klim/TinderProject/photos/')
    fill_sympathy()
    fill_messages()