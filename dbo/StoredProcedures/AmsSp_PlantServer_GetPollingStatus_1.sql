-----------------------------------------------------------------------
-- AmsSp_PlantServer_GetPollingStatus_1
--
--	Get the alertMonitorPolling status for this plant server.
--
-- Inputs --
--	@sPsName - plant server name

--
-- Outputs --
--	@nStatus - polling status; <>0 is enabled, 0 not enabled

--
-- Returns -
--	0 - successful.
--	-1 - Error, did not find plant server in list. 
--
-- Joe Fisher, 9/28/04
--
CREATE PROCEDURE AmsSp_PlantServer_GetPollingStatus_1
@sPsName nvarchar(255),
@nStatus int output
AS

set nocount on
declare @nReturn int
set @nReturn = 0

select @nStatus = cast(AlertMonitorEnabled as int)
from PlantServer with (nolock)
where @sPsName = PlantServerId

-- should have selected at least one row.
if (@@rowcount <> 1)
	set @nReturn = -1

return @nReturn

GO

