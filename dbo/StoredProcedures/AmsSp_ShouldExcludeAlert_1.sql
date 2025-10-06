
-----------------------------------------------------------------------
-- AmsSp_ShouldExcludeAlert_1
--
-- determines whether this alert for the given device should be filtered.
--
-- Inputs -
--	@strAlertId nvarchar(1024)
--	@nBlockKey int
--		This is the Block Key.
--
-- Outputs - 
--  @nShouldExcludeAlert - 0 = should not exclude, 1 = should exclude
--  @sDescription - description of alert from DeviceAlertDesc
--
-- Returns -
--	0 - successful.
--
-- James Kramer 12/03/2007
--
CREATE PROCEDURE AmsSp_ShouldExcludeAlert_1
@strAlertId nvarchar(1024),
@nBlockKey int,
@nShouldExcludeAlert int output,
@sDescription nvarchar (1024) output
AS

set @nShouldExcludeAlert = 0

-- if a device does not have an AlertFilterForDevice entry for the specified AlertId,
-- then the alert should not be filtered/excluded
-- only if the AlertFilterForDevice entry is found should a check be made to see if the
-- Enabled column is set.  If set, the alert is not excluded.  If clear, the alert should be excluded

declare @nEnabled int
-- SCR AOEP00028706 - need to include if we can not find any filters
set @nEnabled = 1
SELECT @nEnabled = AlertFilterForDevice.Enabled, @sDescription = DeviceAlertDesc.Description
FROM AlertFilterForDevice INNER JOIN
	 DeviceMonitorList ON DeviceMonitorList.BlockKey = AlertFilterForDevice.BlockKey INNER JOIN
	 DeviceAlertDesc ON DeviceAlertDesc.AlertDescId = AlertFilterForDevice.AlertDescId INNER JOIN
	 Blocks ON Blocks.BlockKey = DeviceMonitorList.BlockKey INNER JOIN
	 Devices ON Devices.DeviceKey = Blocks.DeviceKey
WHERE DeviceAlertDesc.AlertId = @strAlertId and DeviceAlertDesc.AmsDevRevId = Devices.AmsDevRevId

if (@nEnabled = 0)
begin
	set @nShouldExcludeAlert = 1
end
	
return 0

GO

