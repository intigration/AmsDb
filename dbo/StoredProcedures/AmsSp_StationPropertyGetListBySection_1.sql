
----------------------------------------------------------------------
-- AmsSp_StationPropertyGetListBySection_1
--
-- returns a list of items based on the passed in section and Plant Server.
--
-- Inputs -
--	@sPsNamenvarchar(max) PlantServer name.
--  @sSection nvarchar(256) Section name.
--
-- Outputs -
--  a list of records for that section/PlantServer
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 12/13/2007
--
CREATE PROCEDURE AmsSp_StationPropertyGetListBySection_1
@sPsName nvarchar(1024),
@sSection nvarchar(256)
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

select PlantServerKey, StationInfoPropertySection, StationInfoPropertyKey, StationInfoPropertyValue from StationProperty 
where PlantServerKey = @nPlantServerKey and StationInfoPropertySection = @sSection

return @rtn

GO

