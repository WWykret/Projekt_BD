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



