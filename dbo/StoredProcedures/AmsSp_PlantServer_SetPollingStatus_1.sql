-----------------------------------------------------------------------
-- AmsSp_PlantServer_SetPollingStatus_1
--
--	set the alertMonitorPolling status for this plant server.
--
-- Inputs --
--	@sPsName - plant server name
--	@nStatus - polling status; <>0 is enabled, 0 not enabled
--
-- Outputs --
--
-- Returns -
--	0 - successful.
--	-1 - Error, did not find plant server in list. 
--
-- Joe Fisher, 9/28/04
--
CREATE PROCEDURE AmsSp_PlantServer_SetPollingStatus_1
@sPsName nvarchar(255),
@nStatus int
AS

set nocount on
declare @nReturn int
set @nReturn = 0
declare @bStatus bit
set @bStatus = 0
if (@nStatus <> 0) set @bStatus = 1

update PlantServer with (rowlock) set AlertMonitorEnabled = @bStatus where @sPsName = PlantServerId

-- should have updated one row.
if (@@rowcount <> 1)
	set @nReturn = -1

return @nReturn

GO

