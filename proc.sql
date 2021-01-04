USE Project

IF OBJECT_ID('Register', 'P') IS NOT NULL
	DROP PROCEDURE Register

IF OBJECT_ID('CreateCharacter', 'P') IS NOT NULL
	DROP PROCEDURE CreateCharacter

IF OBJECT_ID('BanPlayer', 'P') IS NOT NULL
	DROP PROCEDURE BanPlayer

IF OBJECT_ID('TryToLogin', 'FN') IS NOT NULL
	DROP FUNCTION TryToLogin

IF OBJECT_ID('CharacterInventory', 'TF') IS NOT NULL
	DROP FUNCTION CharacterInventory

IF OBJECT_ID('PlayerCharacters', 'TF') IS NOT NULL
	DROP FUNCTION PlayerCharacters

IF OBJECT_ID('CharactersInGuild', 'TF') IS NOT NULL
	DROP FUNCTION CharactersInGuild

IF OBJECT_ID('EnemiesInLocation', 'TF') IS NOT NULL
	DROP FUNCTION EnemiesInLocation

IF OBJECT_ID('FriendsInLocation', 'TF') IS NOT NULL
	DROP FUNCTION FriendsInLocation

GO

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

--Funkcja do logowania
CREATE FUNCTION TryToLogin (@Email NVARCHAR(64), @Password NVARCHAR(64))
RETURNS BIT
AS BEGIN
	DECLARE @Res BIT
	IF (EXISTS(SELECT * FROM Players P WHERE Email=@Email AND Pass=@Password) AND NOT EXISTS(SELECT * FROM Players P JOIN Banned B ON P.Player_ID = B.Player_ID WHERE GETDATE() BETWEEN B.Start AND B.Finish AND P.Email=@Email))
		SET @Res = 1
	ELSE
		SET @Res = 0
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
    SELECT It.Name, Inv.Item_lvl, Inv.Item_amount 
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
    SELECT C.Nick, G.Name GuildName, L.Name CurrentLocation, C.Lvl, C.Gold
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
