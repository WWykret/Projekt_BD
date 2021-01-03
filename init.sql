-- Tworzenie pustej bazy danych
IF DB_ID('Project') IS NOT NULL
	DROP DATABASE Project

CREATE DATABASE Project

-- Lista graczy
CREATE TABLE Project.dbo.Players(
	Player_ID INT PRIMARY KEY IDENTITY(1,1),
	Pass NVARCHAR(64) NOT NULL,
	Email NVARCHAR(64) UNIQUE NOT NULL
)

--Lista gildii
CREATE TABLE Project.dbo.Guilds(
	Guild_ID INT PRIMARY KEY IDENTITY(1,1),
	-- Guild_owner INT NOT NULL REFERENCES -- nie wiadomo co references co
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Guild_lvl INT NOT NULL,
	Guild_exp INT NOT NULL
)

--Lista lokacji
CREATE TABLE Project.dbo.Locations(
	Location_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Location_lvl INT NOT NULL
)

-- Lista postaci
CREATE TABLE Project.dbo.Characters(
	Character_ID INT PRIMARY KEY IDENTITY(1,1),
	Player_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Players(Player_ID),
	Guild_ID INT FOREIGN KEY REFERENCES Project.dbo.Guilds(Guild_ID),
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Locations(Location_ID),
	Nick NVARCHAR(32) UNIQUE NOT NULL,
	Max_hp INT NOT NULL,
	Hp INT NOT NULL,
	Max_mana INT NOT NULL,
	Mana INT NOT NULL,
	Lvl INT NOT NULL,
	Character_exp INT NOT NULL,
	Gold INT NOT NULL
)

--Lista przedmiotów
CREATE TABLE Project.dbo.Items (
	Item_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Atack INT,
	Defence INT,
	Mana INT,
	Hp INT
)

--Ekwipunek gracza
CREATE TABLE Project.dbo.Inventory (
	Character_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Characters(Character_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Items(Item_ID),
	Item_lvl INT,
	Item_amount INT NOT NULL,
	PRIMARY KEY (Character_ID, Item_ID, Item_lvl)
)

--Lista wszystkich statusów
CREATE TABLE Project.dbo.Statuses (
	Status_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Atack INT,
	Defence INT,
	Mana INT,
	Hp INT,
	Duration INT NOT NULL, --w sekundach
	Chance FLOAT NOT NULL --procent na na³o¿enie
)

--Lista Efektów
CREATE TABLE Project.dbo.Effects (
	Character_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Characters(Character_ID),
	Status_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Statuses(Status_ID),
	Time_until_end INT NOT NULL
	PRIMARY KEY (Character_ID, Status_ID)
)

--Lista Zbanowanych
CREATE TABLE Project.dbo.Banned (
	Player_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Players(Player_ID),
	Start DATE NOT NULL,
	Finish DATE NOT NULL,
	Reason NVARCHAR(256) NOT NULL
	PRIMARY KEY (Player_ID, Start)
)

--Lista Przeciwników
CREATE TABLE Project.dbo.Enemies (
	Enemy_ID INT PRIMARY KEY IDENTITY(1,1),
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Locations(Location_ID), --potwory przypisane do konkretnych lokacji
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Hp INT NOT NULL,
	Defence INT NOT NULL,
	Atack INT NOT NULL,
	Kill_exp INT NOT NULL,
	Status_on_hit INT REFERENCES Project.dbo.Statuses(Status_ID)
)

--Lista przedmiotów które wypadaj¹
CREATE TABLE Project.dbo.EnemyDrops (
	Enemy_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Enemies(Enemy_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Items(Item_ID),
	Drop_chance FLOAT NOT NULL
	PRIMARY KEY (Enemy_ID, Item_ID)
)

--Lista NPC
CREATE TABLE Project.dbo.NPCs (
	NPC_ID INT PRIMARY KEY IDENTITY(1,1),
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Locations(Location_ID),
	Store_ID INT UNIQUE, --ew. póŸniej dodaæ sequence
	Name NVARCHAR(32) UNIQUE NOT NULL
)

--Lista sklepów
CREATE TABLE Project.dbo.Stores (
	Store_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.NPCs(Store_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Items(Item_ID),
	Item_lvl INT NOT NULL,
	Amount INT NOT NULL,
	Unit_cost INT NOT NULL
	PRIMARY KEY (Store_ID, Item_ID, Item_lvl)
)

--Dom aukcyjny
CREATE TABLE Project.dbo.AuctionHouse (
	Offer_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Seller_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Characters(Character_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Items(Item_ID),
	Item_lvl INT,
	Amount INT NOT NULL,
	Highest_bid INT NOT NULL,
	Highest_bidder INT FOREIGN KEY REFERENCES Project.dbo.Characters(Character_ID),
	Beggin_date DATE NOT NULL,
	End_date DATE NOT NULL
)

--Lista zadañ
CREATE TABLE Project.dbo.Quests(
	Quest_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Min_lvl INT NOT NULL,
	Quest_name NVARCHAR(32) UNIQUE NOT NULL,
	Quest_desc NVARCHAR(256) /*UNIQUE*/ NOT NULL,
	--warunki wygranej
	Npc_ID INT FOREIGN KEY REFERENCES Project.dbo.NPCs(NPC_ID),
	Item_ID INT FOREIGN KEY REFERENCES Project.dbo.Items(Item_ID),
	Item_lvl INT,
	Item_amount INT
)

--Tabela po³¹czeñ zadañ
CREATE TABLE Project.dbo.QuestConnetions(
	Quest_ID INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Quests(Quest_ID),
	Quest_required INT NOT NULL FOREIGN KEY REFERENCES Project.dbo.Quests(Quest_ID),
	PRIMARY KEY (Quest_ID, Quest_required)
)

--Lista nagród
CREATE TABLE Project.dbo.Rewards(
	Quest_ID INT NOT NULL REFERENCES Project.dbo.Quests(Quest_ID),
	Item_ID INT NOT NULL REFERENCES Project.dbo.Items(Item_ID),
	Item_lvl INT,
	Amount INT NOT NULL
	PRIMARY KEY(Quest_ID, Item_ID, Item_lvl)
)