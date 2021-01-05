USE Project

IF OBJECT_ID('Register', 'P') IS NOT NULL
	DROP PROCEDURE Register

IF OBJECT_ID('CreateCharacter', 'P') IS NOT NULL
	DROP PROCEDURE CreateCharacter

IF OBJECT_ID('BanPlayer', 'P') IS NOT NULL
	DROP PROCEDURE BanPlayer

IF OBJECT_ID('TryToLogin', 'FN') IS NOT NULL
	DROP FUNCTION dbo.TryToLogin

IF OBJECT_ID('CharacterInventory', 'IF') IS NOT NULL
	DROP FUNCTION dbo.CharacterInventory

IF OBJECT_ID('PlayerCharacters', 'IF') IS NOT NULL
	DROP FUNCTION dbo.PlayerCharacters

IF OBJECT_ID('CharactersInGuild', 'IF') IS NOT NULL
	DROP FUNCTION dbo.CharactersInGuild

IF OBJECT_ID('EnemiesInLocation', 'IF') IS NOT NULL
	DROP FUNCTION dbo.EnemiesInLocation

IF OBJECT_ID('FriendsInLocation', 'IF') IS NOT NULL
	DROP FUNCTION dbo.FriendsInLocation

GO



<<<<<<< HEAD

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
=======
>>>>>>> 2adfaf4898134eb2764be5fc900b1c60b38dec43
