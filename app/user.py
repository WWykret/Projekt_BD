import pandas as pd
from utility import *


def stage1() -> int:
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


def stage2(player_id: int) -> int:
    print(player_id)
    choice = int(input('Wybierz opcje z listy: '))

    # try:
    if choice == 1:
        player_id = login()
        return player_id
    elif choice == 2:
        register()

    return None


state = 1
# menu
while True:
    cls()
    p_id = None
    if state == 1:
        p_id = stage1()
        if p_id:
            state = 2
    elif state == 2:
        stage2(p_id)

# except Exception:
# break
