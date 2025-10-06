-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetPlantServerName_1
--
-- Get the plantServerName for the device-block.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--
-- Outputs -
--	@sValue nvarchar(1024)	string value
--	
--
-- Returns -
--	0 - successful.
--	-1 - warning- deviceBlockKey not found
--  -2 - error- we had an error while trying to get data.
--
-- Joe Fisher - 10/09/2003
--

CREATE PROCEDURE AmsSp_DevBlk_GetPlantServerName_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sValue = ''
declare @nIdentStatus int

set nocount on

SELECT     @sValue = dbo.PlantServer.PlantServerId
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

