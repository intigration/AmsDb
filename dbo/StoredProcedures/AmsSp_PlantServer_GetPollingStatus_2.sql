-----------------------------------------------------------------------
-- AmsSp_PlantServer_GetPollingStatus_2
--
--	Get the alertMonitorPolling status for all plant servers.
--
-- Inputs --
--
-- Outputs --
--
-- Returns -
--	0 - successful.
--	-1 - Error
--
-- James Kramer 1/30/2008
--
CREATE PROCEDURE AmsSp_PlantServer_GetPollingStatus_2
AS
select cast(AlertMonitorEnabled as int) As Status, PlantServerId As Name
from PlantServer with (nolock)
where PlantServerKey <> -1

return 0

GO

