
-----------------------------------------------------------------------
-- AmsSp_GetAmsUsers_1
--
-- Get Ams users.
--
-- Inputs -
--	none.
--
-- Outputs -
--	recordset consisting of the following columns --
--	UserKey		int	the database table key.
--	UserName	nvarchar(50)	the user name.
--	UserIdentifier  varbinary(255)	the user identifier including password and permissions.
--
-- Returns -
--	returns number of records found.
--	-1 - if no records found.
--
-- Joe Fisher, 11/7/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetAmsUsers_1
AS

declare @iReturnVal int
set @iReturnVal = 0

select UserKey, UserName, cast(UserIdentifier as varbinary(255)) as UserIdentifier
from Users
where (UserKey >= 6)

set @iReturnVal = @@ROWCOUNT

return @iReturnVal

GO

