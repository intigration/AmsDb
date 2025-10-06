
-----------------------------------------------------------------------
-- AmsSp_Device_GetHistoricalConfigList_1
--
-- Note: for FF Server.
--
-- Get configuration change history for device for all blocks.
--
-- Inputs -
--	@strDeviceID nvarchar(256)
--		This is the device identifier.
--
-- Outputs -
--	Recordset containing list of configuration change dates (in GMT).
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 06/24/2003
-- Kevin Mixter, 10/02/2003
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_Device_GetHistoricalConfigList_1
@strDeviceID nvarchar(256)
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

SELECT     DISTINCT TOP 100 PERCENT dbo.EventLog.EventTime, dbo.EventLog.EventIdDay, dbo.EventLog.EventIdFraction, dbo.Devices.Identifier, 
                      dbo.Blocks.BlockKey
FROM         dbo.Devices INNER JOIN
                      dbo.Blocks ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
                      dbo.BlockData ON dbo.Blocks.BlockKey = dbo.BlockData.BlockKey INNER JOIN
                      dbo.EventLog ON dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
WHERE     (dbo.Devices.Identifier = @strDeviceID) AND (dbo.BlockData.ValueMode = 'h')
ORDER BY dbo.EventLog.EventIdDay DESC, dbo.EventLog.EventIdFraction DESC

if (@@ERROR <> 0)
	set @iReturnVal = -1

return @iReturnVal

GO

