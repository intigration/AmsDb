
-----------------------------------------------------------------------
-- AmsSp_GetAmsUserByName_1
--
-- Get Ams user information by Ams user name.
--
-- Inputs -
--	sUserName	nvarchar(50)	the user name.
--
-- Outputs -
--	nDbKey		int		the database table key.
--	sUserIdentifier varbinary(255)	the user identifier including password and permissions.
--	sSSOID		nvarchar(300)	the Single Sign-On ID.
--
-- Returns -
--	returns 0 if user information found.
--	-1 - if unable to get user information.
--
-- Joe Fisher, 10/31/2001
-- Jane Xiao, 11/2/2004 -- return SSOID
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetAmsUserByName_1
@sUserName as nvarchar(50),
@nDbKey as int OUTPUT,
@sUserIdentifier as varbinary(255) OUTPUT,
@sSSOID as nvarchar(300) OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

select @nDbKey = UserKey
        , @sUserIdentifier = cast(UserIdentifier as varbinary(255))
        ,@sSSOID = isnull(SSOID, '')
from Users
where (UserName = @sUserName)

if (@sUserIdentifier IS NULL) AND (@nDbKey IS NULL)
	set @iReturnVal = -1

return @iReturnVal

GO

