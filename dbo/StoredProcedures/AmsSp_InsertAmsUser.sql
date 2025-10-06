----------------------------------------------------------------------------
-- AmsSp_InsertAmsUser
--
--	Insert AmsUser
-- 
-- Returns -
--	-1 - General error.
--
-- Enrico Resurreccion - 03/20/2012

CREATE PROCEDURE AmsSp_InsertAmsUser
@UserName nvarchar(50),
@UserIdentifier nvarchar(255),
@SSOID nvarchar(300),
@UserKey int OUTPUT
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY
	
	--get userKey
	DECLARE @NextUserKey int
	SELECT 
		@NextUserKey = max(UserKey) + 1 
	FROM 
		Users
	
	-- add user to db
	INSERT 
		Users 
	WITH (rowlock) (UserKey, UserName, UserIdentifier, SSOID)
	VALUES (@NextUserKey, @UserName, @UserIdentifier, @SSOID)
	
	--get new ID
	set @UserKey = @NextUserKey

END TRY
BEGIN CATCH
      set @nReturn = -1;  --General error
END CATCH

return @nReturn;

GO

