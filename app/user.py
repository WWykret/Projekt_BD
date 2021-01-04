import pandas as pd
from utility import *


def stage_1():
    print('1. Logowanie')
    print('2. Rejestracja')
    choice = int(input('Wybierz opcje z listy: '))

    # try:
    if choice == 1:
        login()
    elif choice == 2:
        register()


state = 1
# menu
while True:
    cls()
    if state == 1:
        stage_1()

# except Exception:
# break
