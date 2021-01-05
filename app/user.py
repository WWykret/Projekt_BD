from utility import *

cls()

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

wait()

print(f'Wybrano postać o nicku {nick}')

wait()

print('Postacie w tej lokacji: ')
npcs = get_friends(location)
for index, npc in npcs.iterrows():
    print(npc['Name'])
print('Przeciwnicy w tej lokacji: ')
enemies = get_enemies(location)
for index, enemy in enemies.iterrows():
    print(enemy['Name'])

wait()

if input('chcesz walczyć z potworem (t/n)? ') == 't':
    cls()
    stats = get_enemy_stats(enemies.at[2, 'Enemy_ID'])
    print(f'przeciwnik: {enemies.at[2, "Name"]}:')
    print(f"zdrowie: {stats.at[0, 'Hp']}")
    print(f"obrona: {stats.at[0, 'Defence']}")
    print(f"atak: {stats.at[0, 'Attack']}")
    print('---------------------------')
    character_stats = get_character_stats(char_id)
    a, d = get_player_atk_def_hp(char_id)
    print(f'gracz: {nick}')
    print(f"zdrowie: {character_stats.at[0, 'Hp']}/{character_stats.at[0, 'Max_hp']}")
    print(f"obrona: {5 + d}")
    print(f"atak: {5 + a}")
    wait()
    damage_character(char_id, 10)
    if int(character_stats.at[0, 'Hp']) > 0:
        print(f"Walka zakończona. Wygrywa {nick}.")
        give_award(char_id, enemies.at[2, 'Enemy_ID'], location, enemies.at[2, 'Kill_exp'])
    else:
        print(f"Walka zakończona. Wygrywa {enemies.at[2, 'Name']}")
        die(char_id)
