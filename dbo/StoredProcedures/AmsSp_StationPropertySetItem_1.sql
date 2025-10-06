
----------------------------------------------------------------------
-- AmsSp_StationPropertySetItem_1
--
-- set a Station Property Item.
--
-- Inputs -
--	@sPsNamenvarchar(max) PlantServer name.
--  @sSection nvarchar(256) Section name.
--  @sKey nvarchar(256) Item name.
--  @sValue nvarchar(256)
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 12/13/2007
--
CREATE PROCEDURE AmsSp_StationPropertySetItem_1
@sPsName nvarchar(1024),
@sSection nvarchar(256),
@sKey nvarchar(256),
@sValue nvarchar(256)
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

select StationPropertyKey from StationProperty 
where PlantServerKey = @nPlantServerKey and StationInfoPropertySection = @sSection and StationInfoPropertyKey = @sKey

if (@@rowcount = 1)
begin
	-- item already exists, update it
	update StationProperty
	set StationInfoPropertyValue = @sValue
	where PlantServerKey = @nPlantServerKey and StationInfoPropertySection = @sSection and StationInfoPropertyKey = @sKey
end
else
begin
	-- new item
	insert into StationProperty (PlantServerKey, StationInfoPropertySection, StationInfoPropertyKey, StationInfoPropertyValue)
	values (@nPlantServerKey, @sSection, @sKey, @sValue)
end

return @rtn

GO

