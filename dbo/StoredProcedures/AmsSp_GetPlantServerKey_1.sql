
-----------------------------------------------------------------------
-- AmsSp_Get_PlantServerKey_1
--
-- Get the database key of the PlantServer.
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
CREATE  procedure AmsSp_GetPlantServerKey_1
@sName as nvarchar(256),
@nId as integer output
as

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

set @nId = -1

select @nId = PlantServerKey from PlantServer with (nolock) where PlantServer.PlantServerId = @sName

if (@@ROWCOUNT = 0) or (@@ERROR <> 0)
begin
	set @iReturnVal = 1
end

return @iReturnVal

GO

