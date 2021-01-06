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
	Members INT NOT NULL DEFAULT 1,
)

--Lista lokacji
CREATE TABLE Locations(
	Location_ID INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(32) UNIQUE NOT NULL,
	Location_lvl INT NOT NULL
)

CREATE TABLE LocationsConnetions(
	Source_Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID),
	Destination_Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID),
	PRIMARY KEY (Source_Location_ID, Destination_Location_ID)
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
--Lista Zbanowanych
CREATE TABLE Banned (
	Player_ID INT NOT NULL FOREIGN KEY REFERENCES Players(Player_ID) ON DELETE CASCADE,
	Start DATE NOT NULL,
	Finish DATE NOT NULL,
	Reason NVARCHAR(256) NOT NULL
	PRIMARY KEY (Player_ID, Start)
)

--Lista wszystkich NPC
CREATE TABLE NPCs (
	NPC_ID INT PRIMARY KEY IDENTITY(1,1),
	Location_ID INT NOT NULL FOREIGN KEY REFERENCES Locations(Location_ID) ON DELETE CASCADE,
	Name NVARCHAR(32) UNIQUE NOT NULL
)

--Lista Przeciwników
CREATE TABLE Enemies (
	Enemy_ID INT PRIMARY KEY FOREIGN KEY REFERENCES NPCs(NPC_ID) ON DELETE CASCADE,
	Hp INT NOT NULL,
	Defence INT NOT NULL,
	Attack INT NOT NULL,
	Kill_exp INT NOT NULL,
)

--Lista przedmiotów które wypadają
CREATE TABLE EnemyDrops (
	Enemy_ID INT NOT NULL FOREIGN KEY REFERENCES Enemies(Enemy_ID) ON DELETE CASCADE,
	Item_ID INT NOT NULL FOREIGN KEY REFERENCES Items(Item_ID),
	Drop_chance FLOAT NOT NULL
	PRIMARY KEY (Enemy_ID, Item_ID)
)

--Lista Przyjaznych NPC
CREATE TABLE Friends (
	Friend_ID INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES NPCs(NPC_ID) ON DELETE CASCADE,
	Store_ID INT UNIQUE NOT NULL
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
	Bid_amount INT NOT NULL
	PRIMARY KEY (Offer_ID,Bidder_ID)
)

--Lista zadań
CREATE TABLE Quests(
	Quest_ID INT PRIMARY KEY IDENTITY(1,1),
	Min_lvl INT NOT NULL,
	Quest_name NVARCHAR(32) UNIQUE NOT NULL,
	Quest_desc NVARCHAR(256) UNIQUE NOT NULL,
	Quest_Giver INT NOT NULL FOREIGN KEY REFERENCES NPCs(NPC_ID) ON DELETE CASCADE,
	--warunki wygranej
	Npc_ID INT FOREIGN KEY REFERENCES NPCs(NPC_ID) ,
	Item_ID INT FOREIGN KEY REFERENCES Items(Item_ID)  ,
	Item_lvl INT,
	Item_amount INT
)

--lista aktywnych questow
CREATE TABLE QuestsTracker(
	Character_ID INT NOT NULL REFERENCES Characters(Character_ID),
	Quest_ID INT NOT NULL REFERENCES Quests(Quest_ID),
	Quest_Status INT NOT NULL
	PRIMARY KEY (Quest_ID,Character_ID)
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
	SELECT B.Player_ID, B.Finish, B.Reason
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
CREATE FUNCTION CharacterInventory (@Character_ID INT)
RETURNS TABLE
AS
RETURN
    SELECT It.Name, It.Item_ID, Inv.Item_lvl, Inv.Item_amount 
    FROM Inventory Inv
	LEFT JOIN Items It ON Inv.Item_ID=It.Item_ID
	WHERE Inv.Character_ID=@Character_ID
GO

--funkcja wypisujaca postacie utworzone przez danego gracza
CREATE FUNCTION PlayerCharacters (@Player_ID INT)
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
CREATE FUNCTION CharactersInGuild (@Guild_ID INT)
RETURNS TABLE
AS
RETURN
    SELECT Nick, Lvl, Gold
    FROM Characters C
	WHERE C.Guild_ID=@Guild_ID
GO


--funkcja wypisuj¹ca wszystkich przeciwnikow w danej lokacji
CREATE FUNCTION EnemiesInLocation (@Location_ID INT)
RETURNS TABLE
AS
RETURN
    SELECT E.Enemy_ID, N.Name, E.Kill_exp
    FROM Enemies E 
	LEFT JOIN NPCs N ON E.Enemy_ID=N.NPC_ID
	WHERE N.Location_ID=@Location_ID
GO


--funkcja wypisuj¹ca wszystkich przyjaznych NPC w danej lokacji
CREATE FUNCTION FriendsInLocation (@Location_ID INT)
RETURNS TABLE
AS
RETURN
    SELECT F.Friend_ID, N.Name, F.Store_ID
    FROM Friends F
	LEFT JOIN NPCs N ON F.Friend_ID=N.NPC_ID
	WHERE N.Location_ID=@Location_ID
GO

--funkcja wypisuj¹ca wszystkich lokacje do ktorych moze przejsc postac
CREATE FUNCTION AccessibleLocations (@Character_ID INT)
RETURNS TABLE
AS
RETURN
    SELECT L.Location_ID, L.Name, L.Location_lvl
    FROM (
		SELECT *
		FROM Characters
		WHERE Character_ID=@Character_ID
	) C
	LEFT JOIN LocationsConnetions Lc ON C.Location_ID=Lc.Source_Location_ID
	LEFT JOIN Locations L ON Lc.Destination_Location_ID=L.Location_ID
GO

--funkcja wypisuj¹ca wszystkie questy dawane przez danego przyjaznego NPC
CREATE FUNCTION NPCsQuests (@Friend_ID INT)
RETURNS TABLE
AS
RETURN
    SELECT Q.Quest_ID, Q.Quest_name, Q.Min_lvl
    FROM Quests Q
	WHERE Q.Quest_Giver=@Friend_ID

GO

--funkcja wypisuj¹ca wszystkie przedmioty w danym sklepie
CREATE FUNCTION ItemsInStore (@Store_ID INT)
RETURNS TABLE
AS
RETURN
    SELECT S.Item_ID, I.Name, S.Item_lvl, S.Unit_cost, S.Amount
    FROM Stores S
	LEFT JOIN Items I ON S.Item_ID=I.Item_ID
	WHERE S.Store_ID=@Store_ID

GO

--funkcja wypisuj¹ca wszystkie nagrody przyznane za dany quest
CREATE FUNCTION RewardsForQuest (@Quest_ID INT)
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
		WHERE Lc.Source_Location_ID = (
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

CREATE PROCEDURE RemoveMember(@Character_ID INT, @Guild_ID INT)
AS
BEGIN
	IF(EXISTS(
		SELECT *
		FROM Guilds
		WHERE Guild_ID=@Guild_ID AND Guild_owner=@Character_ID
		))
	BEGIN
		DELETE FROM Guilds
		WHERE Guild_ID=@Guild_ID;
	END
	ELSE 
	BEGIN
		UPDATE Guilds
		SET Members-=1
		WHERE Guild_ID=@Guild_ID;

		UPDATE Characters
		SET Guild_ID=NULL
		WHERE Character_ID=@Character_ID AND Guild_ID=@Guild_ID;
	END
END
GO

CREATE PROCEDURE AddMember(@Character_ID INT, @Guild_ID INT)
AS
BEGIN
	IF(EXISTS(
		SELECT *
		FROM Characters
		WHERE Character_ID=@Character_ID AND Guild_ID IS NOT NULL
		))
	BEGIN
	DECLARE @CharactersGuild INT
	SET @CharactersGuild=(
		SELECT Guild_ID
		FROM Characters
		WHERE Character_ID=@Character_ID)

		EXEC RemoveMember @Character_ID=@Character_ID , @Guild_ID=@CharactersGuild
	END
	UPDATE Guilds
	SET Members+=1
	WHERE Guild_ID=@Guild_ID;

	UPDATE Characters
	SET Guild_ID=@Guild_ID
	WHERE Character_ID=@Character_ID;

END
GO


CREATE PROCEDURE Death(@Character_ID INT)
AS
BEGIN
	
	DECLARE @Max_hp INT
	SET @Max_hp=(
		SELECT Max_hp
		FROM Characters
		WHERE Character_ID=@Character_ID)

	UPDATE Characters
	SET HP=@Max_hp, Gold=0
	WHERE Character_ID=@Character_ID
	
END
GO

CREATE PROCEDURE Level_up(@Character_ID INT)
AS
BEGIN
	
		UPDATE Characters
		SET Lvl+=1, Max_hp+=10
		WHERE Character_ID=@Character_ID

		UPDATE Characters
		SET Hp=(
			SELECT Max_hp
			FROM Characters
			WHERE Character_ID=@Character_ID)
		WHERE Character_ID=@Character_ID
	
END
GO


CREATE PROCEDURE Gain_Exp(@Character_ID INT,@Exp_gain INT)
AS
BEGIN
	
	DECLARE @Max_hp INT
	SET @Max_hp=(
		SELECT Max_hp
		FROM Characters
		WHERE Character_ID=@Character_ID)

	UPDATE Characters
	SET Character_exp+=@Exp_gain
	WHERE Character_ID=@Character_ID

	WHILE(
		SELECT Character_exp
		FROM Characters
		WHERE Character_ID=@Character_ID)>=1000
	BEGIN
		UPDATE Characters
		SET Character_exp-=1000
		WHERE Character_ID=@Character_ID

		EXEC Level_up @Character_ID=@Character_ID

	END
	
END
GO

CREATE PROCEDURE AcceptQuest(@Character_ID INT,@Quest_ID INT)
AS
BEGIN
	INSERT INTO QuestsTracker VALUES
	(@Character_ID, @Quest_ID, 1)

END
GO

CREATE PROCEDURE ReturnQuest(@Character_ID INT,@Quest_ID INT)
AS
BEGIN
	UPDATE QuestsTracker
	SET Quest_Status=0
	WHERE Character_ID=@Character_ID AND Quest_ID=@Quest_ID

END
GO

CREATE PROCEDURE BidOnAuction(@Character_ID INT,@Offer_ID INT, @Gold INT)
AS
BEGIN
	DECLARE @Gold_Difrence INT
	SET @Gold_Difrence=@Gold
	IF(EXISTS(
		SELECT *
		FROM AuctionHouseBids
		WHERE Offer_ID=@Offer_ID AND Bidder_ID=@Character_ID
	))
	BEGIN
		SET @Gold_Difrence-=(
			SELECT Bid_amount
			FROM AuctionHouseBids
			WHERE Offer_ID=@Offer_ID AND Bidder_ID=@Character_ID)

		UPDATE AuctionHouseBids
		SET Bid_amount=@Gold
		WHERE Offer_ID=@Offer_ID AND Bidder_ID=@Character_ID
	END
	ELSE BEGIN
		INSERT INTO AuctionHouseBids VALUES
		(@Offer_ID, @Character_ID, @Gold)
	END

	UPDATE Characters
	SET @Gold-=@Gold_Difrence
	WHERE Character_ID=@Character_ID

END
GO


--wyzwalacze

CREATE TRIGGER addItem ON Inventory--dodaje tylko jeden wierszu
INSTEAD OF INSERT
AS BEGIN

	DECLARE @Character_ID INT;
    DECLARE @Item_ID INT;
    DECLARE @Item_lvl INT;
	DECLARE @Item_amount INT;
	DECLARE @Item_Hp INT;


    SELECT @Character_ID = Character_ID, @Item_ID = I.Item_ID, @Item_lvl = Item_lvl, @Item_amount=Item_amount , @Item_Hp=Hp 
	FROM INSERTED I
	JOIN Items It ON It.Item_ID=I.Item_ID;

    IF(EXISTS(
		SELECT *
		FROM Inventory I
		WHERE I.Character_ID=@Character_ID AND I.Item_ID=@Item_ID AND I.Item_lvl=@Item_lvl
	))
	BEGIN
		UPDATE Inventory
		SET Item_amount+=(SELECT Item_amount FROM INSERTED )
		WHERE Character_ID=@Character_ID AND Item_ID=@Item_ID AND Item_lvl=@Item_lvl

	END 
	ELSE
	BEGIN
		/*
		SELECT *
		INTO Inventory
		FROM INSERTED
		*/

		INSERT INTO Inventory
		VALUES (@Character_ID, @Item_ID, @Item_lvl,@Item_amount)
	END

	IF(@Item_Hp IS NOT NULL)
	BEGIN
	UPDATE Characters
	SET Max_hp+=@Item_lvl*@Item_amount*@Item_Hp
	WHERE Character_ID=@Character_ID

	END

END
GO

CREATE TRIGGER deleteItem ON Inventory--dodaje tylko jeden wierszu
INSTEAD OF DELETE
AS BEGIN

	DECLARE @Character_ID INT;
    DECLARE @Item_ID INT;
    DECLARE @Item_lvl INT;
	DECLARE @Item_amount INT;

	DECLARE @Item_Hp INT;
	
    SELECT @Character_ID = Character_ID, @Item_ID = D.Item_ID , @Item_lvl = Item_lvl, @Item_amount=Item_amount , @Item_Hp=Hp 
	FROM DELETED D
	JOIN Items I ON D.Item_ID=I.Item_ID;

	

    IF(@Item_amount<(
		SELECT Item_amount
		FROM Inventory I
		WHERE I.Character_ID=@Character_ID AND I.Item_ID=@Item_ID AND I.Item_lvl=@Item_lvl
	))
	BEGIN

		UPDATE Inventory
		SET Item_amount-=(SELECT Item_amount FROM INSERTED )
		WHERE Character_ID=@Character_ID AND Item_ID=@Item_ID AND Item_lvl=@Item_lvl

	END 
	ELSE
	BEGIN
		SET @Item_amount=(
			SELECT Item_amount
			FROM Inventory I
			WHERE I.Character_ID=@Character_ID AND I.Item_ID=@Item_ID AND I.Item_lvl=@Item_lvl)
		
		DELETE FROM Inventory
		WHERE Character_ID=@Character_ID AND Item_ID=@Item_ID AND Item_lvl=@Item_lvl

	END

	IF(@Item_Hp IS NOT NULL)
	BEGIN
	UPDATE Characters
	SET Max_hp-=@Item_lvl*@Item_amount*@Item_Hp
	WHERE Character_ID=@Character_ID

	END
END
GO

CREATE TRIGGER DeleteGuild ON Guilds
INSTEAD OF DELETE 
AS BEGIN

	DECLARE @Giuld_ID INT;
	SET @Giuld_ID =(
		SELECT Guild_ID
		FROM DELETED
	)
	UPDATE Characters
	SET Guild_ID=NULL
	WHERE Guild_ID=@Giuld_ID

	DELETE FROM Guilds
	WHERE Guild_ID=@Giuld_ID
END
GO


CREATE TRIGGER CreteGuild ON Guilds
AFTER INSERT
AS BEGIN

	DECLARE @Character_ID INT;
	DECLARE @Giuld_ID INT;

	SET @Character_ID =(
		SELECT Guild_owner
		FROM INSERTED
	)
	
	
	SET @Giuld_ID =(
		SELECT Guild_ID
		FROM INSERTED
	)

	UPDATE Characters
	SET Guild_ID=@Giuld_ID
	WHERE Character_ID=@Character_ID

END
GO

CREATE TRIGGER DeleteCharacter ON Characters
INSTEAD OF DELETE
AS BEGIN
	DECLARE @Character_ID INT
	DECLARE @Guild_ID INT

	SELECT @Character_ID = Character_ID, @Guild_ID=Guild_ID
	FROM DELETED;

	EXEC RemoveMember @Character_ID=@Character_ID , @Guild_ID=@Guild_ID

	DELETE FROM Inventory
	WHERE Character_ID=@Character_ID

	DELETE FROM Characters
	WHERE Character_ID=@Character_ID

END

GO

CREATE TRIGGER DestroyLocation ON Locations
INSTEAD OF DELETE
AS BEGIN

	DECLARE @Location_ID INT
	SET @Location_ID=(
		SELECT Location_ID
		FROM DELETED)

	DELETE FROM LocationsConnetions
	WHERE Source_Location_ID=@Location_ID OR Destination_Location_ID=@Location_ID

	DELETE FROM Locations
	WHERE Location_ID=Location_ID

END
GO



INSERT INTO Players VALUES
('password 123', 'email1@wp.pl'),
('password 123', 'email2@wp.pl'),
('password 123', 'email3@wp.pl')

INSERT INTO Locations VALUES
('pi�mowy jar', 1),
('pi�mowy gaj', 2),
('Sala wyk�adowa', 3)

INSERT INTO Characters(Player_ID, Nick, Location_ID, Lvl) VALUES
(1, 'Dunk_man1', 1, 2),
(1, 'Dunk_man2', 2, 1),
(1, 'Dunk_man3', 3, 1),
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
(3, 'Gewis³aw'),
(1, 'Genowefa'),
(1, 'Rafa³ Kawa'),
(1, 'Kolos z ASD'),
(1, 'Prokekt z BD'),
(2, 'Jan Pawel 2'),
(3, 'Jan Pawel 3'),
(2, 'Pani Sekretarka')

INSERT INTO Banned VALUES
(3, GETDATE(), DATEADD(DAY, 3, GETDATE()), 'Wylgaryzmy na czacie')

INSERT INTO Friends VALUES
(1, 1),
(2, 3),
(3, 2),
(9, 4)

INSERT INTO Enemies VALUES
(4, 10, 10, 10, 10),
(5, 20, 5, 10, 10),
(6, 5, 20, 5, 10),
(7,3,4,2,2137),
(8,2,1,10,2137)

INSERT INTO Items VALUES
('Mlot Kawy', 10, NULL, NULL),
('pierscie� ASD', NULL, 10, NULL),
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
(2, 2, 99, 5, 1000),
(1, 3, 1, 10, 300),
(2, 2, 9, 5, 1000),
(3, 2, 8, 10, 200),
(4, 3, 10, 10, 300)

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



------


INSERT INTO Banned VALUES
(3, DATEADD(DAY, -13, GETDATE()), DATEADD(DAY, -4, GETDATE()), 'N-word')


EXEC AddMember @Character_ID=2,  @Guild_ID=1

EXEC AddMember @Character_ID=4,  @Guild_ID=2

EXEC AddMember @Character_ID=6,  @Guild_ID=2

EXEC AddMember @Character_ID=2,  @Guild_ID=2

EXEC AddMember @Character_ID=6,  @Guild_ID=1

--EXEC AddMember @Character_ID=3,  @Guild_ID=1

SELECT * 
FROM Players
SELECT * 
FROM Guilds
SELECT * 
FROM Locations
SELECT * 
FROM LocationsConnetions
SELECT * 
FROM Characters
SELECT * 
FROM Inventory
SELECT * 
FROM Banned
SELECT * 
FROM NPCs
SELECT * 
FROM Enemies
SELECT * 
FROM EnemyDrops
SELECT * 
FROM Friends
SELECT * 
FROM Stores
SELECT * 
FROM AuctionHouse
SELECT * 
FROM AuctionHouseBids
SELECT * 
FROM Quests
SELECT * 
FROM QuestsTracker
SELECT * 
FROM Rewards

SELECT *
FROM CurrentlyBanned

SELECT dbo.TryToLogin ('email1@wp.pl', 'password 123')
SELECT dbo.TryToLogin ('email2@wp.pl', 'password 123')
SELECT dbo.TryToLogin ('email3@wp.pl', 'password 123')
SELECT dbo.TryToLogin ('email2@wp.pl', 'password 1234')
SELECT dbo.TryToLogin ('sxggs', 'fe52hhd')


SELECT *
FROM CharacterInventory (1)
SELECT *
FROM CharacterInventory (2)
SELECT *
FROM CharacterInventory (3)
SELECT *
FROM CharacterInventory (4)

SELECT *
FROM PlayerCharacters(1)
SELECT *
FROM PlayerCharacters(2)

SELECT *
FROM CharactersInGuild(1)
SELECT *
FROM CharactersInGuild(2)

SELECT *
FROM EnemiesInLocation(1)
SELECT *
FROM EnemiesInLocation(2)
SELECT *
FROM EnemiesInLocation(3)

SELECT *
FROM FriendsInLocation(1)
SELECT *
FROM FriendsInLocation(2)
SELECT *
FROM FriendsInLocation(3)

SELECT *
FROM AccessibleLocations(1)
SELECT *
FROM AccessibleLocations(2)
SELECT *
FROM AccessibleLocations(3)

SELECT *
FROM NPCsQuests(2)
SELECT *
FROM NPCsQuests(3)

SELECT *
FROM ItemsInStore(1)
SELECT *
FROM ItemsInStore(2)
SELECT *
FROM ItemsInStore(3)
SELECT *
FROM ItemsInStore(4)

SELECT *
FROM RewardsForQuest(1)
 


 