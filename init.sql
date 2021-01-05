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
	Attack INT,
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
--to chyba jest w sumie nie potrzebne
/*
--Lista wszystkich statusów
CREATE TABLE Statuses (
	Status_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Attack INT,
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
*/
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
	Attack INT NOT NULL,
	Kill_exp INT NOT NULL,
	--Status_on_hit INT REFERENCES Statuses(Status_ID)  --to jest potencjalny powut zeby zachowac statusy, mozna tego uzyc do wyzwalacza
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
	--Amount INT NOT NULL, --to lepiej pominac, przyjac ze liczba jest inf
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

------procedury i funkcje i reszta gowna

----widoki

GO
--Widok pokazujacy aktualnie zbanowanych graczy
CREATE VIEW CurrentlyBanned AS
	SELECT B.Player_ID
	FROM Banned B
	WHERE GETDATE() BETWEEN B.Start AND B.Finish
GO

----funkcje

--Funkcja do logowania
CREATE FUNCTION TryToLogin (@Email NVARCHAR(64), @Password NVARCHAR(64))
RETURNS INT
AS BEGIN
	DECLARE @Res INT
	IF (EXISTS(SELECT * FROM Players P WHERE Email=@Email AND Pass=@Password) AND NOT EXISTS(SELECT * FROM Players P JOIN Banned B ON P.Player_ID = B.Player_ID WHERE GETDATE() BETWEEN B.Start AND B.Finish AND P.Email=@Email))
		SET @Res = (SELECT Player_ID FROM Players WHERE Email=@Email)
	ELSE
		SET @Res = -1
	RETURN @Res
END
GO

--funkcja wypisujaca przedmioty nalezace do danej postaci
CREATE FUNCTION CharacterInventory (
    @Character_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT It.Name, It.Item_ID, Inv.Item_lvl, Inv.Item_amount 
    FROM Inventory Inv
	LEFT JOIN Items It ON Inv.Item_ID=It.Item_ID
	WHERE Inv.Character_ID=@Character_ID
GO

--funkcja wypisujaca postacie utworzone przez danego gracza
CREATE FUNCTION PlayerCharacters (
    @Player_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT C.Character_ID, Nick, G.Name GuildName, L.Location_ID CurrentLocation, C.Lvl, C.Gold
    FROM Characters C
	LEFT JOIN Guilds G ON C.Guild_ID=G.Guild_ID
	LEFT JOIN Locations L ON C.Location_ID=L.Location_ID
	WHERE C.Player_ID=@Player_ID
GO

--funkcja wypisuj¹ca postacie nalezace do danej guildi
CREATE FUNCTION CharactersInGuild (
    @Guild_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT Nick, Lvl, Gold
    FROM Characters C
	WHERE C.Guild_ID=@Guild_ID
GO


--funkcja wypisuj¹ca wszystkich przeciwnikow w danej lokacji
CREATE FUNCTION EnemiesInLocation (
    @Location_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT E.Enemy_ID, N.Name
    FROM Enemies E 
	LEFT JOIN NPCs N ON E.Enemy_ID=N.NPC_ID
	WHERE N.Location_ID=@Location_ID
GO


--funkcja wypisuj¹ca wszystkich przyjaznych NPC w danej lokacji
CREATE FUNCTION FriendsInLocation (
    @Location_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT F.Friend_ID, N.Name, F.Store_ID
    FROM Friends F
	LEFT JOIN NPCs N ON F.Friend_ID=N.NPC_ID
	WHERE N.Location_ID=@Location_ID
GO

--funkcja wypisuj¹ca wszystkich lokacje do ktorych moze przejsc postac
CREATE FUNCTION AccessibleLocations (
    @Character_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT L.Location_ID, L.Name, L.Location_lvl
    FROM (
		SELECT *
		FROM Characters
		WHERE Character_ID=@Character_ID
	) C
	LEFT JOIN LocationsConnetions Lc ON C.Location_ID=Lc.Source_Location__ID
	LEFT JOIN Locations L ON Lc.Destination_Location_ID=L.Location_ID
GO

--funkcja wypisuj¹ca wszystkie questy dawane przez danego przyjaznego NPC
CREATE FUNCTION NPCsQuests (
    @Friend_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT Q.Quest_ID, Q.Quest_name, Q.Min_lvl
    FROM Quests Q
	WHERE Q.Quest_Giver=@Friend_ID

GO

--funkcja wypisuj¹ca wszystkie questy dawane przez danego przyjaznego NPC
CREATE FUNCTION AccessibleQuests (
    @Friend_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT Q.Quest_ID, Q.Quest_name, Q.Min_lvl
    FROM Quests Q
	WHERE Q.Quest_Giver=@Friend_ID

GO

--funkcja wypisuj¹ca wszystkie przedmioty w danym sklepie
CREATE FUNCTION ItemsInStore (
    @Store_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT S.Item_ID, I.Name, S.Item_lvl, S.Unit_cost
    FROM Stores S
	LEFT JOIN Items I ON S.Item_ID=I.Item_ID
	WHERE S.Store_ID=@Store_ID

GO

--funkcja wypisuj¹ca wszystkie nagrody przyznane za dany quest
CREATE FUNCTION RwardsForQuest (
    @Quest_ID INT
)
RETURNS TABLE
AS
RETURN
    SELECT R.Item_ID, I.Name, R.Item_lvl, R.Amount
    FROM Rewards R
	LEFT JOIN Items I ON R.Item_ID=I.Item_ID
	WHERE R.Quest_ID=@Quest_ID

GO

----procedury

--Procedura do rejestracji
CREATE PROCEDURE Register (@Email NVARCHAR(64), @Password NVARCHAR(64))
AS
	IF @Email NOT IN (SELECT Email FROM Players)
		INSERT INTO Players VALUES (@Password, @Email)

GO

--Procedura do dodawania postaci
CREATE PROCEDURE CreateCharacter(@PlayerID INT, @Nick NVARCHAR(32))
AS
	IF @Nick NOT IN (SELECT Email FROM Players)
		INSERT INTO Characters(Player_ID, Nick) VALUES (@PlayerID, @Nick)

GO

CREATE PROCEDURE BanPlayer(@Nick NVARCHAR(32), @Duration INT, @Reason NVARCHAR(256))
AS
	DECLARE @PlayerID INT
	SET @PlayerID = (SELECT Player_ID FROM Characters WHERE Nick=@Nick)
	DECLARE @EndDate DATE
	SET @EndDate = DATEADD(DAY, @Duration, GETDATE())
	INSERT INTO Banned VALUES (@PlayerID, GETDATE(), @EndDate, @Reason)

GO

CREATE PROCEDURE AttemptToMove(@Character_ID INT, @Destination_ID INT)
AS
BEGIN
  DECLARE @Res INT
	IF (EXISTS(
		SELECT *
		FROM LocationsConnetions Lc
		JOIN Locations L ON Lc.Destination_Location_ID=L.Location_ID
		WHERE Lc.Source_Location__ID = (
			SELECT Location_ID
			FROM Characters
			WHERE Character_ID=@Character_ID)
		AND
			Lc.Destination_Location_ID = @Destination_ID
		AND
			L.Location_lvl <= (
			SELECT Lvl
			FROM Characters
			WHERE Character_ID=@Character_ID)
	))
	BEGIN
		SET @Res = 1
		UPDATE Characters
		SET Location_ID=@Destination_ID
		WHERE Character_ID=@Character_ID
	END
	ELSE SET @Res = 0
	RETURN @Res
END
GO

CREATE PROCEDURE AttemptToBuy(@Character_ID INT, @Store_ID INT, @Item_ID INT, @Item_lvl INT, @Amount INT)
AS
BEGIN
	DECLARE @Res INT
	IF (EXISTS(
	SELECT *
	FROM Stores S
	WHERE S.Store_ID=@Store_ID AND S.Item_ID=@Item_ID AND S.Item_lvl=@Item_lvl AND 
	S.Item_lvl<=(
		SELECT Lvl
		FROM Characters
		WHERE Character_ID=@Character_ID)
	AND S.Unit_cost<= @Amount*(
		SELECT Gold
		FROM Characters
		WHERE Character_ID=@Character_ID)
	))
	BEGIN
		SET @Res = 1

		UPDATE Characters
		SET Gold-=@Amount*(
			SELECT S.Unit_cost
			FROM Stores S
			WHERE S.Store_ID=@Store_ID AND S.Item_ID=@Item_ID AND S.Item_lvl=@Item_lvl
		)
		WHERE Character_ID=@Character_ID

		INSERT INTO Inventory
		VALUES (@Character_ID, @Item_ID, @Item_lvl,@Amount)

	END
	ELSE SET @Res = 0
	RETURN @Res
END
GO
--wyzwalacze

CREATE TRIGGER addItem ON Inventory
INSTEAD OF INSERT
AS BEGIN

	DECLARE @Character_ID INT;
    DECLARE @Item_ID INT;
    DECLARE @Item_lvl INT;
	DECLARE @Item_amount INT;
	
    SELECT @Character_ID = Character_ID, @Item_ID = Item_lvl, @Item_lvl = Item_lvl, @Item_amount=Item_amount 
	FROM INSERTED;

    IF(EXISTS(
		SELECT *
		FROM Inventory I
		WHERE I.Character_ID=@Character_ID AND I.Item_ID=@Item_ID AND I.Item_lvl=@Item_lvl
	))
	BEGIN

		UPDATE Inventory
		SET Item_amount+=Item_amount+(SELECT Item_amount FROM INSERTED )
		WHERE Character_ID=@Character_ID AND Item_ID=@Item_ID AND Item_lvl=@Item_lvl

	END 
	ELSE
	BEGIN

		INSERT INTO Inventory
		VALUES (@Character_ID, @Item_ID, @Item_lvl,@Item_amount)

	END
	

END
GO
/*
CREATE TRIGGER AutoLevelUp ON Characters
INSTEAD  OF UPDATE
AS BEGIN

	DECLARE @Character_ID INT;
    DECLARE @Exp_Gain INT;

    SELECT @Character_ID = Character_ID, @Exp_Gain=Character_exp
	FROM INSERTED;

    IF(@Character_exp>=1000)
	BEGIN

		UPDATE Characters
		SET Lvl+=@Character_exp/1000, Character_exp=@Character_exp%1000
		WHERE Character_ID=@Character_ID

	END 

	DECLARE @Guild_ID INT;

	SET @Guild_ID=(
		SELECT Guild_ID
		FROM Characters
		WHERE @Character_ID=Character_ID)

	IF(@Guild_ID IS NOT NULL)
		UPDATE Characters
		SET Lvl+=@Character_exp/1000, Character_exp=@Character_exp%1000
		WHERE Character_ID=@Character_ID

	END 
END
GO
*/
--WSTAWIANIE PIERWSZYCH PRZYK£ADOWYCH DANYCH DO TABEL
INSERT INTO Players VALUES
(N'password 123', 'email1@wp.pl'),
(N'password 321', 'email2@wp.pl'),
(N'password xxx', 'email3@wp.pl'),
(N'password 832', 'email4@wp.pl'),
(N'password 666', 'email5@wp.pl')

INSERT INTO Locations VALUES
(N'Pi¿mowy jar', 1),
(N'Jarowy pi¿m', 2),
(N'Mordor', 3),
(N'FAIS', 4),
(N'Gwiazda neutronowa', 5)

INSERT INTO Characters(Player_ID, Nick, Location_ID) VALUES
(1, 'Dunk_man1', 1),
(1, 'Dunk_man2', 1),
(1, 'Dunk_man3', 1),
(1, 'Dunk_man4', 1)

INSERT INTO NPCs VALUES
(1, 'Gerarda'),
(1, 'Gewis³aw'),
(1, 'Genowefa'),
(1, 'Rafa³ Kawa'),
(1, 'Kolos z ASD'),
(1, 'Prokekt z BD')

INSERT INTO Friends VALUES
(1, 1),
(2, NULL),
(3, 2)

INSERT INTO Enemies VALUES
(4, 10, 10, 10, 10),
(5, 20, 5, 10, 10),
(6, 5, 20, 5, 10)

INSERT INTO Items Values
('M³ot Kawy', 10, NULL, NULL),
('pierœcieñ ASD', NULL, 10, NULL),
('Zwolnienie z egz', NULL, NULL, 20),
('Strza³a w kolanie', NULL, NULL, NULL)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(1, 1, 1, 3)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(1, 2, 2, 2)

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(1, 3, 3, 1)

INSERT INTO EnemyDrops(Enemy_ID, Item_ID, Drop_chance) VALUES
(4, 4, 0.9),
(5, 4, 0.9),
(6, 4, 0.9)

SELECT * FROM dbo.CharacterInventory(1) Inv JOIN Items Ite ON Ite.Item_ID = Inv.Item_ID
SELECT * FROM Characters

INSERT INTO Inventory(Character_ID, Item_ID, Item_lvl, Item_amount) VALUES
(1, 4, 1, 1)