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


def login():
    cls()
    email = input('Email: ')
    password = input('Hasło: ')
    success = pd.read_sql_query(f'''
        SELECT dbo.TryToLogin(N'{email}', N'{password}')
    ''', conn).bool()
    conn.commit()
    if success:
        print('OK')
    else:
        print('FAIL')


def register():
    cls()
    email = input('Email: ')
    password = input('Hasło: ')
    conn.execute(f'''
        EXEC Register @Email=N'{email}', @Password=N'{password}'
    ''')
    conn.commit()


# menu
while True:
    cls()
    print('1. Logowanie')
    print('2. Rejestracja')
    choice = int(input('Wybierz opcje z listy: '))

    # try:
    if choice == 1:
        login()
    elif choice == 2:
        register()
# except Exception:
# break
