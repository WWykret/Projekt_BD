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

cls = lambda: os.system('cls')


def ban_player():
    cls()
    nick = input('podaj nick gracza do zbanowania: ')
    player_id = int(pd.read_sql_query(
        f'SELECT P.Player_ID FROM Players AS P JOIN Characters AS C ON C.Player_ID = P.Player_ID WHERE C.Nick = N\'{nick}\'',
        conn
    )['Player_ID'])
    interval = int(input('podaj na ile dni banowac: '))
    reason = input('Podaj powod na bana: ')
    print(f'INSERT INTO Banned VALUES ({player_id}, GETDATE(), GETDATE(), N\'{reason}\')')
    conn.execute(f'''INSERT INTO Banned VALUES ({player_id}, GETDATE(), GETDATE(),
                    N\'{reason}\')''')
    conn.commit()


# menu
while True:
    cls()
    print('1. Ban player')
    print('2. Exit')
    choice = int(input('Wybierz opcje z listy: '))

    # try:
    if choice == 1:
        ban_player()
    elif choice == 2:
        break
# except Exception:
# break
