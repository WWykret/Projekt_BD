import pandas as pd
from utility import *


def stage_1() -> int:
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


def stage_2(player_id: int) -> int:
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
    player_id = None
    if state == 1:
        if stage_1():
            state = 2
    elif state == 2:
        stage2(player_id)

# except Exception:
# break
