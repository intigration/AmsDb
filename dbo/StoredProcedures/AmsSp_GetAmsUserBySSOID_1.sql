
-----------------------------------------------------------------------
-- AmsSp_GetAmsUserBySSOID_1
--
-- Get Ams user information by Ams Single Sign-On ID.
--
-- Inputs -
--	sSSOID	nvarchar(300)	the AMS Single Sign-On ID.
--
-- Outputs -
--	sUserName   	nvarchar(50)	the AMS User Name.
--	nDbKey		int		the database table key.
--	sUserIdentifier varbinary(255)	the user identifier including password and permissions.
--
-- Returns -
--	returns 0 if user information found.
--	-1 - if unable to get user information.
--
-- Jane Xiao, 11/2/2004 
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetAmsUserBySSOID_1
@sSSOID as nvarchar(300),
@sUserName as nvarchar(50) OUTPUT,
@nDbKey as int OUTPUT,
@sUserIdentifier as varbinary(255) OUTPUT

AS

declare @iReturnVal int
set @iReturnVal = 0

select @sUserName = UserName
          ,@nDbKey = UserKey
          ,@sUserIdentifier = cast(UserIdentifier as varbinary(255))
from Users
where (SSOID = @sSSOID)

if (@sUserName IS NULL) AND (@nDbKey IS NULL)
	set @iReturnVal = -1

return @iReturnVal

GO

