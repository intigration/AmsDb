-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetPlantServerKey_1
--
-- Get the plantServerName for the device-block.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--
-- Outputs -
--	@nPlantServerKey int  the plant server database key.
--	
--
-- Returns -
--	0 - successful.
--	-1 - warning- deviceBlockKey not found
--  -2 - error- we had an error while trying to get data.
--
-- Joe Fisher - 09/23/2004
--

CREATE PROCEDURE AmsSp_DevBlk_GetPlantServerKey_1
@nDevLevelBlockKey int,
@nPlantServerKey int output
AS
set nocount on
declare @iReturnVal int
set @iReturnVal = 0
set @nPlantServerKey = -1

SELECT     @nPlantServerKey = dbo.PlantServer.PlantServerKey
FROM         dbo.DeviceLocation with (nolock) INNER JOIN
                      dbo.PlantServer with (nolock) ON dbo.DeviceLocation.PlantServerKey = dbo.PlantServer.PlantServerKey
WHERE     (dbo.DeviceLocation.BlockKey = @nDevLevelBlockKey)

if @@rowcount = 0
begin
	set @iReturnVal = -1
end
if @@error <> 0
begin
	set @iReturnVal = -2
end

return @iReturnVal

GO

