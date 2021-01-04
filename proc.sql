USE Project

IF OBJECT_ID('Register', 'P') IS NOT NULL
	DROP PROCEDURE Register

IF OBJECT_ID('CreateCharacter', 'P') IS NOT NULL
	DROP PROCEDURE CreateCharacter

IF OBJECT_ID('BanPlayer', 'P') IS NOT NULL
	DROP PROCEDURE BanPlayer

IF OBJECT_ID('TryToLogin', 'FN') IS NOT NULL
	DROP FUNCTION TryToLogin

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