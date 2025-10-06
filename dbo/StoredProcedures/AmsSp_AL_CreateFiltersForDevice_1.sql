
-----------------------------------------------------------------------
-- AmsSp_AL_CreateFiltersForDevice_1
--
--	creates the alert filters for the given device
--
-- Inputs --
--	@nBlockKey - block key of the device
--
-- Outputs --
--
-- Recordset output --
--
-- Returns -
--	0 - successful.
--	-1 - Error
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_AL_CreateFiltersForDevice_1
@nBlockKey int
AS

set nocount on
declare @nReturn int
set @nReturn = 0

-- delete all alert filters for this device
delete from AlertFilterForDevice where BlockKey = @nBlockKey;

WITH SELECT_DEVICE_ALERT_DESC AS
(
	SELECT DeviceMonitorList.BlockKey, DeviceAlertDesc.AlertDescId, Enabled = 1
	FROM DeviceMonitorList INNER JOIN
         Blocks ON DeviceMonitorList.BlockKey = Blocks.BlockKey INNER JOIN
         Devices ON Blocks.DeviceKey = Devices.DeviceKey INNER JOIN
         DeviceAlertDesc ON Devices.AmsDevRevId = DeviceAlertDesc.AmsDevRevId	
	WHERE Blocks.BlockKey = @nBlockKey	
) INSERT INTO AlertFilterForDevice SELECT * FROM SELECT_DEVICE_ALERT_DESC

return @nReturn

GO

