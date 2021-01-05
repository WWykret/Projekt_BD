import pyodbc
import os
import pandas as pd

with open('./server_name') as f:
    server = f.read()

conn = pyodbc.connect(
    'Driver={SQL Server};'
    f'Server={server};'
    'Database=Project;'
    'Trusted_Connection=yes;'
)


def cls():
    os.system('cls')


# FUNKCJE
def login(email, password) -> int:
    cls()
    player_id = int(pd.read_sql_query(f'''
        SELECT dbo.TryToLogin(N'{email}', N'{password}')
    ''', conn))
    conn.commit()
    return player_id


def register():
    cls()
    email = input('Email: ')
    password = input('Hasło: ')
    conn.execute(f'''
        EXEC Register @Email=N'{email}', @Password=N'{password}'
    ''')
    conn.commit()


def ban_player():
    cls()
    nick = input('Nick: ')
    duration = int(input('Duration: '))
    reason = input('Reason: ')
    conn.execute(f'''
        EXEC BanPlayer @Nick=N'{nick}', @Duration='{duration}', @Reason=N'{reason}'
    ''')
    conn.commit()


def get_characters(player_id):
    pass


def get_location(character_id):
    pass


def get_friends(location_id):
    pass


def get_enemies(location_id):
    pass
