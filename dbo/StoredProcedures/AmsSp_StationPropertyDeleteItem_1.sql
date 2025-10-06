
----------------------------------------------------------------------
-- AmsSp_StationPropertyDeleteItem_1
--
-- deletes a Station Property Item.
--
-- Inputs -
--	@sPsNamenvarchar(max) PlantServer name.
--  @sSection nvarchar(256) Section name.
--  @sKey nvarchar(256) Item name.
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 12/13/2007
--
CREATE PROCEDURE AmsSp_StationPropertyDeleteItem_1
@sPsName nvarchar(1024),
@sSection nvarchar(256),
@sKey nvarchar(256)
AS

declare @rtn int
set @rtn = 0

declare @nPlantServerKey int
set @nPlantServerKey = -1

select @nPlantServerKey = PlantServerKey from PlantServer where PlantServerId = @sPsName

if (@nPlantServerKey = -1)
begin
	return -1
end

delete from StationProperty
where PlantServerKey = @nPlantServerKey and StationInfoPropertySection = @sSection and StationInfoPropertyKey = @sKey

return @rtn

GO

