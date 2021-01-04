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


def f():
    cls()
    nick = input('Nick: ')
    duration = int(input('Duration: '))
    reason = input('Reason: ')
    conn.execute(f'''
        EXEC BanPlayer @Nick=N'{nick}', @Duration='{duration}', @Reason=N'{reason}'
    ''')
    conn.commit()


# menu
while True:
    cls()
    print('1. Ban player')
    print('2. Exit')
    choice = int(input('Wybierz opcje z listy: '))

    # try:
    if choice == 1:
        f()
    elif choice == 2:
        break
# except Exception:
# break
