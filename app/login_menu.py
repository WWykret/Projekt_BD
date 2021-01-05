import pandas as pd
from utility import login, register


def login_menu():
    print('1. Logowanie')
    print('2. Rejestracja')
    choice = int(input('Wybierz opcje z listy: '))

    # try:
    if choice == 1:
        player_id = login()
        return player_id
    elif choice == 2:
        register()

    return None
