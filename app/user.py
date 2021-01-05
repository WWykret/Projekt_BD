from utility import *
import pandas as pd

# normalnie użytkownik wpisuje sam login i hasło
player_id = login('email1@wp.pl', 'password 123')

print('Dstępne postaci: ')
characters = get_characters(player_id)

nick, char_id, location = None, None, None
for index, row in characters.iterrows():
    print(row['Nick'])
    if not nick:
        pass
        nick = str(row['Nick'])
        char_id = int(row['Character_ID'])
        location = int(row['CurrentLocation'])

print(f'Wybrano postać o nicku {nick}')
# print('\n\nPostacie w tej lokacji: ')
# npcs = get_friends(location)
# for npc in npcs:
#     print(npc['Name'])
# print('\n\nPrzeciwnicy w tej lokacji: ')
# enemies = get_enemies(location)
# for enemy in enemies:
#     print(enemy['Name'])
