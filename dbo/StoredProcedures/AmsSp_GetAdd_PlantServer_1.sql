
-----------------------------------------------------------------------
-- AmsSp_GetAdd_PlantServer_1
--
-- Get the database id of the PlantServer; if the PlantServer is not found
-- it is added.
--
-- Inputs -
--	@sName	nvarchar(256)	the PlantServer name.
--
-- Outputs -
--	@nId	int	the PlantServer database id.
--
-- Returns -
--	0 - success else non-zero.
--
-- Joe Fisher, 12/19/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE  procedure AmsSp_GetAdd_PlantServer_1
@sName as nvarchar(256),
@nId as integer output
as

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

set @nId = -1

exec @iReturnVal = AmsSp_GetPlantServerKey_1 @sName, @nId output
if (@iReturnVal <> 0)
begin
	set @iReturnVal = 0
	-- plantServer name not present, attempt to add it.
	-- we need to derive the database key from the maximum id currently in the table.
	select @nId = max(PlantServerKey) from PlantServer
	select @nId = @nId + 1
	insert into PlantServer with (rowlock) (PlantServerKey, PlantServerId, AlertMonitorEnabled) values (@nId, @sName, 0)
	if (@@ROWCOUNT = 0)
	begin
		set @iReturnVal = 1
	end
end

return @iReturnVal

GO

