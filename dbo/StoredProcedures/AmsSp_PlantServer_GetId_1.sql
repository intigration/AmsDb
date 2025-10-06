-----------------------------------------------------------------------
-- AmsSp_PlantServer_GetId_1
--
-- Get the plantServerName and return the key.
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
--	-1 - plantserver not found.
--	-2 - other error
--
-- Joe Fisher - 4/25/2006
--

CREATE PROCEDURE AmsSp_PlantServer_GetId_1
@sPlantServerName	nvarchar(255),
@nPlantServerKey	int output
AS
declare @iReturnVal int
set @iReturnVal = -1

SELECT     @nPlantServerKey = PlantServerKey
from       PlantServer with (nolock)
WHERE     (PlantServerId = @sPlantServerName)

if (@@ROWCOUNT <> 0)
begin
	set @iReturnVal = 0
end
else
begin
	set @nPlantServerKey = -999
	set @iReturnVal = -1
end

return @iReturnVal

GO

