from utility import *

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
