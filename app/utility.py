import pyodbc
import os
import pandas as pd
import numpy as np

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


def wait():
    input('...')
    cls()


# FUNKCJE
def login(email, password):
    player_id = pd.read_sql_query(f'''
        SELECT dbo.TryToLogin(N'{email}', N'{password}')
    ''', conn)
    conn.commit()
    return int(player_id.iat[0, 0])


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
    characters = pd.read_sql(f'''
        SELECT * FROM dbo.PlayerCharacters('{player_id}')
    ''', conn)
    return characters


def get_friends(location_id):
    npcs = pd.read_sql_query(f'''
        SELECT * FROM dbo.FriendsInLocation('{location_id}')
    ''', conn)
    return npcs


def get_enemies(location_id):
    enemies = pd.read_sql_query(f'''
            SELECT * FROM dbo.EnemiesInLocation('{location_id}')
        ''', conn)
    return enemies


def get_enemy_stats(enemy_id):
    return pd.read_sql_query(f'''
        SELECT * FROM Enemies WHERE Enemy_ID={enemy_id}
    ''', conn)


def get_character_stats(character_id):
    return pd.read_sql_query(f'''
        SELECT * FROM Characters WHERE Character_ID={character_id}
    ''', conn)


def get_player_items(character_id):
    return pd.read_sql_query(f'''
        SELECT * FROM dbo.CharacterInventory({character_id}) Inv JOIN Items Ite ON Ite.Item_ID = Inv.Item_ID
    ''', conn)


def get_player_atk_def_hp(character_id):
    items = get_player_items(character_id)
    attack, defence = 0, 0
    for index, item in items.iterrows():
        if not pd.isnull(item['Attack']):
            print(item['Attack'])
            attack += item['Attack'] * item['Item_lvl'] if not pd.isnull(item['Item_lvl']) != np.nan else 1
        # if item['Defence'] != np.nan:
        #     print(item)
        #     print(f"{int(item['Defence'])} --- {int(item['Item_lvl'])}")
        #     defence += int(item['Defence']) * (int(item['Item_lvl']) if item['Item_lvl'] != np.nan else 1)
    return attack, defence
