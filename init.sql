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

-- Lista postaci
CREATE TABLE Characters(
	Character_ID INT PRIMARY KEY IDENTITY(1,1),
	Player_ID INT NOT NULL FOREIGN KEY REFERENCES Players(Player_ID),
	Nick NVARCHAR(32) UNIQUE NOT NULL,
	Guild_ID INT FOREIGN KEY REFERENCES Guilds(Guild_ID) DEFAULT NULL,
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID) DEFAULT 1,
	Max_hp INT NOT NULL DEFAULT 100,
	Hp INT NOT NULL DEFAULT 100,
	Lvl INT NOT NULL DEFAULT 1,
	Character_exp INT NOT NULL DEFAULT 0,
	Gold INT NOT NULL DEFAULT 50
)

ALTER TABLE Guilds ADD CONSTRAINT fk_owner FOREIGN KEY(Guild_owner) REFERENCES Characters(Character_ID)

--Lista przedmiot�w
CREATE TABLE Items (
	Item_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Atack INT,
	Defence INT,
	Hp INT
)

--Ekwipunek gracza
CREATE TABLE Inventory (
	Character_ID INT NOT NULL FOREIGN KEY REFERENCES Characters(Character_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Items(Item_ID),
	Item_lvl INT,
	Item_amount INT NOT NULL,
	PRIMARY KEY (Character_ID, Item_ID, Item_lvl)
)

--Lista wszystkich status�w
CREATE TABLE Statuses (
	Status_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Atack INT,
	Defence INT,
	Hp INT,
	Duration INT NOT NULL, --w turach
	Chance FLOAT NOT NULL --procent na na�o�enie
)

--Lista Efekt�w
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

--Lista Przeciwnik�w
CREATE TABLE Enemies (
	Enemy_ID INT PRIMARY KEY IDENTITY(1,1),
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID), --potwory przypisane do konkretnych lokacji
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Hp INT NOT NULL,
	Defence INT NOT NULL,
	Atack INT NOT NULL,
	Kill_exp INT NOT NULL,
	Status_on_hit INT REFERENCES Statuses(Status_ID)
)

--Lista przedmiot�w kt�re wypadaj�
CREATE TABLE EnemyDrops (
	Enemy_ID INT NOT NULL FOREIGN KEY REFERENCES Enemies(Enemy_ID),
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Items(Item_ID),
	Drop_chance FLOAT NOT NULL
	PRIMARY KEY (Enemy_ID, Item_ID)
)

--Lista NPC
CREATE TABLE NPCs (
	NPC_ID INT PRIMARY KEY IDENTITY(1,1),
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID),
	Store_ID INT UNIQUE, --ew. p�niej doda� sequence
	Name NVARCHAR(32) UNIQUE NOT NULL
)

--Lista sklep�w
CREATE TABLE Stores (
	Store_ID INT NOT NULL FOREIGN KEY REFERENCES NPCs(Store_ID),
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
	Amount INT NOT NULL,
	Highest_bid INT NOT NULL,
	Highest_bidder INT FOREIGN KEY REFERENCES Characters(Character_ID),
	Beggin_date DATE NOT NULL,
	End_date DATE NOT NULL
)

--Lista zada�
CREATE TABLE Quests(
	Quest_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Min_lvl INT NOT NULL,
	Quest_name NVARCHAR(32) UNIQUE NOT NULL,
	Quest_desc NVARCHAR(256) /*UNIQUE*/ NOT NULL,
	--warunki wygranej
	Npc_ID INT FOREIGN KEY REFERENCES NPCs(NPC_ID),
	Item_ID INT FOREIGN KEY REFERENCES Items(Item_ID),
	Item_lvl INT,
	Item_amount INT
)

--Tabela po��cze� zada�
CREATE TABLE QuestConnetions(
	Quest_ID INT NOT NULL FOREIGN KEY REFERENCES Quests(Quest_ID),
	Quest_required INT NOT NULL FOREIGN KEY REFERENCES Quests(Quest_ID),
	PRIMARY KEY (Quest_ID, Quest_required)
)

--Lista nagr�d
CREATE TABLE Rewards(
	Quest_ID INT NOT NULL REFERENCES Quests(Quest_ID),
	Item_ID INT NOT NULL REFERENCES Items(Item_ID),
	Item_lvl INT,
	Amount INT NOT NULL
	PRIMARY KEY(Quest_ID, Item_ID, Item_lvl)
)

--WSTAWIANIE PIERWSZYCH PRZYK�ADOWYCH DANYCH DO TABEL
INSERT INTO Players VALUES
(N'password 123', 'email@wp.pl'),
(N'password 321', 'email1@wp.pl'),
(N'password xxx', 'email2@wp.pl'),
(N'password 832', 'email3@wp.pl'),
(N'password 666', 'email4@wp.pl')

INSERT INTO Locations VALUES
(N'Pi�mowy jar', 1),
(N'Jarowy pi�m', 2),
(N'Mordor', 3),
(N'FAIS', 4),
(N'Gwiazda neutronowa', 5)

INSERT INTO Characters(Player_ID, Nick) VALUES
(1, N'Dunk_man'),
(1, N'Dunk_man2'),
(2, N'Dunk_man3'),
(3, N'Dunk_man4'),
(4, N'Dunk_man5'),
(4, N'Dunk_man6'),
(5, N'Dunk_man7')

-- SELECT * FROM Banned

-- EXEC CreateCharacter @Nick=N'1257', @PlayerID=1

-- EXEC BanPlayer @Nick='Dunk_man', @Duration=5, @Reason='I Like placek'

-- SELECT dbo.Register(N'email4@wp.pl', N'pass123')

SELECT * FROM Players

SELECT Email FROM Players