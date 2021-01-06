USE Project

INSERT INTO Players VALUES
('password 123', 'email1@wp.pl'),
('password 123', 'email2@wp.pl'),
('password 123', 'email3@wp.pl')

INSERT INTO Locations VALUES
('pi¿mowy jar', 1),
('pi¿mowy gaj', 2),
('Sala wyk³adowa', 3)

INSERT INTO Characters(Player_ID, Nick, Location_ID, Lvl) VALUES
(1, 'Dunk_man1', 1, 2),
(1, 'Dunk_man2', 1, 1),
(1, 'Dunk_man3', 1, 1),
(1, 'Dunk_man4', 1, 1),
(2, 'kawa_22', 1, 1),
(3, 'kawa_420', 1, 1)

INSERT INTO Guilds(Guild_owner, Name) VALUES
(1, 'Whatever')

INSERT INTO Guilds(Guild_owner, Name) VALUES
(3, 'Whatever Delux')


INSERT INTO LocationsConnetions VALUES
(1, 2),
(2, 1),
(1, 3),
(3, 1)

INSERT INTO NPCs VALUES
(1, 'Gerarda'),
(1, 'GewisÂ³aw'),
(1, 'Genowefa'),
(1, 'RafaÂ³ Kawa'),
(1, 'Kolos z ASD'),
(1, 'Prokekt z BD')

INSERT INTO Banned VALUES
(3, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'Wylgaryzmy na czacie')

INSERT INTO Friends VALUES
(1, 1),
(2, NULL),
(3, 2)

INSERT INTO Enemies VALUES
(4, 10, 10, 10, 10),
(5, 20, 5, 10, 10),
(6, 5, 20, 5, 10)

INSERT INTO Items VALUES
('Mlot Kawy', 10, NULL, NULL),
('pierscieñ ASD', NULL, 10, NULL),
('Zwolnienie z egz', NULL, NULL, 20),
('Strzala w kolanie', NULL, NULL, NULL)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(1, 1, 1, 3)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(1, 2, 2, 2)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(1, 3, 3, 1)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(1, 4, 1, 1)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(2, 2, 3, 10)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(2, 1, 10, 1)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(3, 4, 1, 1)


INSERT INTO EnemyDrops(Enemy_ID, Item_ID, Drop_chance) VALUES
(4, 4, 0.9),
(5, 4, 0.9),
(6, 4, 0.9)


INSERT INTO Stores(Store_ID, Item_ID, Item_lvl, Amount, Unit_cost) VALUES
(1, 1, 5, 10, 100),
(1, 2, 8, 10, 200),
(1, 3, 10, 10, 300),
(2, 2, 99, 5, 1000)

INSERT INTO Quests(Min_lvl, Quest_name, Quest_desc, Quest_Giver, Npc_ID, Item_ID, Item_lvl, Item_amount) VALUES
(2, 'poszukiwacze dzikow', 'jak w naziwe zadania', 3, 2, NULL, NULL, NULL)

INSERT INTO QuestsTracker VALUES
(4, 1, 1)

INSERT INTO Rewards VALUES
(1, 1, 2, 3),
(1, 3, 2, 3)

INSERT INTO AuctionHouse VALUES
(3, 3, 1, 300, GETDATE(), DATEADD(DAY, 3, GETDATE()))

INSERT INTO AuctionHouseBids VALUES
(1, 5, 500)

INSERT INTO Banned VALUES
(3, DATEADD(DAY, -13, GETDATE()), DATEADD(DAY, -4, GETDATE()), 'N-word')

EXEC AddMember @Character_ID=2,  @Guild_ID=1

EXEC AddMember @Character_ID=4,  @Guild_ID=2

EXEC AddMember @Character_ID=6,  @Guild_ID=2

USE master

