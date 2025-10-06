
-----------------------------------------------------------------------
-- AmsSp_GetAdd_SnapOnDataOwnerId
--
-- Get the database id of the SnapOnDataOwner; if the owner is not found
-- it is added.
--
-- Inputs -
--	@sName	nvarchar(255)	the owner name.
--
-- Outputs -
--	@nId	int	the owner database id.
--
-- Returns -
--	0 - success else non-zero.
--
-- Joe Fisher, 8/30/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
create procedure AmsSp_GetAdd_SnapOnDataOwnerId
@sName as nvarchar(255),
@nId as integer output
as

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

set @nId = -1

select @nId = SnapOnDataOwnerId from SnapOnDataOwners where SnapOnDataOwners.name = @sName

if (@@ROWCOUNT = 0)
begin
	-- data owner not present, attempt to add it.
	insert into SnapOnDataOwners (Name) values (@sName)
	if (@@ERROR = 0)
	begin
		set @nId = @@IDENTITY
	end
end

if (@@ERROR <> 0)
begin
	set @iReturnVal = 1
end

return @iReturnVal

GO

