-----------------------------------------------------------------------
-- AmsSp_AmsUser_GetKey_1
--
-- Gets the Ams user Key; if not found then returns File Server User Key.
--
-- Inputs -
--	@strAmsUserName nvarchar(256)
--		This is the name of the user.
--	@strFileServerName nvarchar(256)
--		This is the name of the AMS File Server.
--
-- Outputs -
--	@iAmsUserKey int
--		The AmsUserKey.
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get user record.
--
-- Jane Xiao, 06/16/2003
--
CREATE PROCEDURE AmsSp_AmsUser_GetKey_1
@strAmsUserName nvarchar(255),
@strFileServerName nvarchar(255),
@iAmsUserKey int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get AmsUserKey if present.
select @iAmsUserKey = UserKey
from Users with (nolock)
where UserName = @strAmsUserName

if (@@ROWCOUNT <> 1)
   begin
	-- user name not found.
	-- use file Server Name
	select @iAmsUserKey = UserKey
	from Users with (nolock)
	where UserName = @strFileServerName
	if (@@ROWCOUNT = 0)
	begin
		--add the file server user name
		declare @NextUserKey int
		select @NextUserKey = max(UserKey) + 1 from Users
		-- add file server user to db
		insert Users with (rowlock) (UserKey, UserName, UserIdentifier)
		values (@NextUserKey, @strFileServerName, '')
		if (@@ERROR <> 0)
		begin
			set @iReturnVal = -1
		end
		else --get new ID
		begin
			set @iAmsUserKey = @NextUserKey
		end	
	end
    end

return @iReturnVal

GO

