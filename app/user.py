from utility import *
import pandas as pd

# normalnie użytkownik wpisuje sam login i hasło
player_id = login('Dunk_man', 'password 123')

print('Dstępne postaci: ')
characters = get_characters(player_id)

nick, char_id, location = None, None, None
for character in characters:
    print(str(character['Nick']))
    if not nick:
        nick = str(character['Nick'])
        char_id = int(character['Character_ID'])
        location = str(character['CurrentLocation'])

print(f'Wybrano postać o nicku {nick}')
print('\n\nPostacie w tej lokacji: ')
npcs = get_friends(location)
for npc in npcs:
    print(npc['Name'])
print('\n\nPrzeciwnicy w tej lokacji: ')
enemies = get_enemies(location)
for enemy in enemies:
    print(enemy['Name'])


