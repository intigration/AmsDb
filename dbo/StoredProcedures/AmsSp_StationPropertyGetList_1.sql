
----------------------------------------------------------------------
-- AmsSp_StationPropertyGetList_1
--
-- returns a list of items based on the passed in Plant Server.
--
-- Inputs -
--	@sPsNamenvarchar(max) PlantServer name.
--
-- Outputs -
--  a list of records for that PlantServer
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 12/13/2007
--
CREATE PROCEDURE AmsSp_StationPropertyGetList_1
@sPsName nvarchar(1024)
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
where PlantServerKey = @nPlantServerKey

return @rtn

GO

