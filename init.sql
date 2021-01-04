USE master

-- Tworzenie pustej bazy danych
IF DB_ID('Project') IS NOT NULL
	DROP DATABASE Project

CREATE DATABASE Project

USE Project

-- Lista graczy
CREATE TABLE Players(
	Player_ID INT PRIMARY KEY IDENTITY(1,1),
	Pass NVARCHAR(64) NOT NULL,
	Email NVARCHAR(64) UNIQUE NOT NULL
)

--Lista gildii
CREATE TABLE Guilds(
	Guild_ID INT PRIMARY KEY IDENTITY(1,1),
	Guild_owner INT NOT NULL,
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Guild_lvl INT NOT NULL,
	Guild_exp INT NOT NULL
)

--Lista lokacji
CREATE TABLE Locations(
	Location_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Location_lvl INT NOT NULL
)

CREATE TABLE LocationsConnetions(
	Source_Location__ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID),
	Destination_Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID),
	PRIMARY KEY (Source_Location__ID, Destination_Location_ID)
)

-- Lista postaci
CREATE TABLE Characters(
	Character_ID INT PRIMARY KEY IDENTITY(1,1),
	Player_ID INT NOT NULL FOREIGN KEY REFERENCES Players(Player_ID),
	Guild_ID INT FOREIGN KEY REFERENCES Guilds(Guild_ID),
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID),
	Nick NVARCHAR(32) UNIQUE NOT NULL,
	Max_hp INT NOT NULL DEFAULT 100,
	Hp INT NOT NULL DEFAULT 100,
	Lvl INT NOT NULL DEFAULT 1,
	Character_exp INT NOT NULL DEFAULT 0,
	Gold INT NOT NULL DEFAULT 50
)

ALTER TABLE Guilds ADD CONSTRAINT fk_owner FOREIGN KEY(Guild_owner) REFERENCES Characters(Character_ID)

--Lista przedmiotów
CREATE TABLE Items (
	Item_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Atack INT,
	Defence INT,
	Hp INT
)

--Ekwipunek gracza
CREATE TABLE Inventory (
	Character_ID INT NOT NULL FOREIGN KEY REFERENCES Characters(Character_ID) ,
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Items(Item_ID) ,
	Item_lvl INT,
	Item_amount INT NOT NULL,
	PRIMARY KEY (Character_ID, Item_ID, Item_lvl)
)

--Lista wszystkich statusów
CREATE TABLE Statuses (
	Status_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Atack INT,
	Defence INT,
	Hp INT,
	Duration INT NOT NULL, --w turach
	Chance FLOAT NOT NULL --procent na na³o¿enie
)

--Lista Efektów
CREATE TABLE Effects (
	Character_ID INT NOT NULL FOREIGN KEY REFERENCES Characters(Character_ID),
	Status_ID INT NOT NULL FOREIGN KEY REFERENCES Statuses(Status_ID),
	Time_until_end INT NOT NULL
	PRIMARY KEY (Character_ID, Status_ID)
)

--Lista Zbanowanych
CREATE TABLE Banned (
	Player_ID INT NOT NULL FOREIGN KEY REFERENCES Players(Player_ID),
	Start DATE NOT NULL,
	Finish DATE NOT NULL,
	Reason NVARCHAR(256) NOT NULL
	PRIMARY KEY (Player_ID, Start)
)

--Lista wszystkich NPC
CREATE TABLE NPCs (
	NPC_ID INT PRIMARY KEY IDENTITY(1,1),
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID),
	Name NVARCHAR(32) UNIQUE NOT NULL
)

--Lista Przeciwników
CREATE TABLE Enemies (
	Enemy_ID INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES NPCs(NPC_ID),
	Hp INT NOT NULL,
	Defence INT NOT NULL,
	Atack INT NOT NULL,
	Kill_exp INT NOT NULL,
	Status_on_hit INT REFERENCES Statuses(Status_ID)
)

--Lista przedmiotów które wypadaj¹
CREATE TABLE EnemyDrops (
	Enemy_ID INT NOT NULL FOREIGN KEY REFERENCES Enemies(Enemy_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Items(Item_ID),
	Drop_chance FLOAT NOT NULL
	PRIMARY KEY (Enemy_ID, Item_ID)
)

--Lista Przyjaznych NPC
CREATE TABLE Friends (
	Friend_ID INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES NPCs(NPC_ID),
	Store_ID INT UNIQUE, --ew. póŸniej dodaæ sequence
)

--Lista sklepów
CREATE TABLE Stores (
	Store_ID INT NOT NULL FOREIGN KEY REFERENCES Friends(Store_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Items(Item_ID),
	Item_lvl INT NOT NULL,
	Amount INT NOT NULL,
	Unit_cost INT NOT NULL
	PRIMARY KEY (Store_ID, Item_ID, Item_lvl)
)

--Dom aukcyjny
CREATE TABLE AuctionHouse (
	Offer_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Seller_ID INT NOT NULL FOREIGN KEY REFERENCES Characters(Character_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Items(Item_ID),
	Item_lvl INT,
	Starting_Price INT NOT NULL,
	Beggin_date DATE NOT NULL,
	End_date DATE NOT NULL
)

--oferty w domu aukcyjnym
CREATE TABLE AuctionHouseBids (
	Offer_ID INT NOT NULL FOREIGN KEY REFERENCES AuctionHouse(Offer_ID),
	Bidder_ID INT NOT NULL FOREIGN KEY REFERENCES Characters(Character_ID),
	Bid_date DATE NOT NULL,
	Bid_amount INT NOT NULL
	PRIMARY KEY (Offer_ID,Bidder_ID,Bid_date)
)

--Lista zadañ
CREATE TABLE Quests(
	Quest_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Min_lvl INT NOT NULL,
	Quest_name NVARCHAR(32) UNIQUE NOT NULL,
	Quest_desc NVARCHAR(256) /*UNIQUE*/ NOT NULL,
	Quest_Giver  INT FOREIGN KEY REFERENCES NPCs(NPC_ID),
	--warunki wygranej
	Npc_ID INT FOREIGN KEY REFERENCES NPCs(NPC_ID) ,
	Item_ID INT FOREIGN KEY REFERENCES Items(Item_ID)  ,
	Item_lvl INT,
	Item_amount INT
)

--Lista nagród
CREATE TABLE Rewards(
	Quest_ID INT NOT NULL REFERENCES Quests(Quest_ID) ,
	Item_ID INT NOT NULL REFERENCES Items(Item_ID) ,
	Item_lvl INT,
	Amount INT NOT NULL
	PRIMARY KEY(Quest_ID, Item_ID, Item_lvl)
)
/*
--WSTAWIANIE PIERWSZYCH PRZYK£ADOWYCH DANYCH DO TABEL
INSERT INTO Players VALUES
(N'password 123', 'email@wp.pl'),
(N'password 321', 'email@wp.pl'),
(N'password xxx', 'email@wp.pl'),
(N'password 832', 'email@wp.pl'),
(N'password 666', 'email@wp.pl')

INSERT INTO Locations VALUES
(N'Pi¿mowy jar', 1),
(N'Jarowy pi¿m', 2),
(N'Mordor', 3),
(N'FAIS', 4),
(N'Gwiazda neutronowa', 5)

-- INSERT INTO Characters VALUES
*/

