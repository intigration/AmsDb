-----------------------------------------------------------------------
-- AmsSp_IsDeviceInAlertMonitor_1
--
-- Check if devices from a station is in alert monitor
--
-- Inputs -
-- @sPlantServerName nvarchar(1024)
--
-- Outputs -
-- @bInAlertMonitor int
--
-- Returns -
--	  0 - successful.
--	- 1 - error
--
-- Junilo Pagobo - 8/14/2009
--
CREATE PROCEDURE AmsSp_IsDeviceInAlertMonitor_1
@sPlantServerName nvarchar(1024),
@bInAlertMonitor int output
AS
declare @rtn int
set @rtn = 0				--Begin with a good state
set @bInAlertMonitor = 0	--Assume no device in the alert monitor list

BEGIN TRY
	IF exists (
		SELECT *
		FROM  PlantServer INNER JOIN
			  DeviceLocation ON PlantServer.PlantServerKey = DeviceLocation.PlantServerKey INNER JOIN
			  Blocks ON DeviceLocation.BlockKey = Blocks.BlockKey INNER JOIN
			  DeviceMonitorList ON Blocks.BlockKey = DeviceMonitorList.BlockKey
		WHERE (PlantServer.PlantServerId = @sPlantServerName)
	)
	begin
		-- Device(s) on the given plant server is/are in the alert monitor list.
		set @bInAlertMonitor = 1
	end

END TRY
BEGIN CATCH
	set @rtn = -1
END CATCH

return @rtn

GO

