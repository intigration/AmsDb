-----------------------------------------------------------------------
-- AmsSp_PlantServer_GetAddId_1
--
-- GetAdd the plantServerName and return the key.
--
--
-- Inputs -
--	@sPlantServerName	nvarchar(255)
--
-- Outputs -
--	@nPlantServerKey	int
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to add the information.
--
-- Joe Fisher - 8/14/2003
--

CREATE PROCEDURE AmsSp_PlantServer_GetAddId_1
@sPlantServerName	nvarchar(255),
@nPlantServerKey	int output
AS
declare @iReturnVal int
set @iReturnVal = 0

SELECT     @nPlantServerKey = PlantServerKey
from       PlantServer with (nolock)
WHERE     (PlantServerId = @sPlantServerName)

if (@@ROWCOUNT = 0)
begin
	-- entry not found- add it.
	select @nPlantServerKey = max(PlantServerKey) + 1 from PlantServer
	if (@nPlantServerKey is null)
	begin
		set @nPlantServerKey = 0
	end
	insert PlantServer with (rowlock) (PlantServerKey,
				PlantServerId,
				AlertMonitorEnabled)
		values	   (@nPlantServerKey,
			   @sPlantServerName,
			   0)
	if @@error <> 0
	begin
		set @iReturnVal = -1
		return @iReturnVal
	end

end

return @iReturnVal

GO

