

-----------------------------------------------------------------------
-- AmsSp_Device_GetHistoricalConfigList_2
--
-- Note: For Both HART and FF.
--
-- Get configuration change history for device for all blocks.
-- This Sp is a updated version of msSp_Device_GetHistoricalConfigList_1
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
-- Ying Xu, 09/24/2003
-- Kevin Mixter, 10/02/2003
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_Device_GetHistoricalConfigList_2
@sMfrName as nvarchar(255),
@sProtocolName as nvarchar(255),
@sDeviceTypeName as nvarchar(255),
@sDeviceRevisionName as nvarchar(255),
@sSerialNumber as nvarchar(255)
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

SELECT     DISTINCT TOP 100 PERCENT dbo.EventLog.EventTime, dbo.EventLog.EventIdDay, dbo.EventLog.EventIdFraction 
FROM         dbo.Devices INNER JOIN
                      dbo.Blocks ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
                      dbo.BlockData ON dbo.Blocks.BlockKey = dbo.BlockData.BlockKey INNER JOIN
                      dbo.EventLog ON dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction INNER JOIN
		      dbo.DeviceRevisions ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId INNER JOIN
		      dbo.DeviceTypes ON dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId INNER JOIN
		      dbo.MfrProtocols ON dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId INNER JOIN
		      dbo.Manufacturers ON dbo.MfrProtocols.AmsMfrNameId = dbo.Manufacturers.AmsMfrNameId INNER JOIN
		      dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId 
WHERE     (dbo.Manufacturers.Name=@sMfrName) and
	  (dbo.DeviceTypes.Name=@sDeviceTypeName) AND
	  (dbo.DeviceRevisions.Name=@sDeviceRevisionName) AND
	  (dbo.Devices.Identifier=@sSerialNumber) AND
	  (dbo.DeviceProtocols.Name=@sProtocolName) AND
	  (dbo.BlockData.ValueMode = 'h')
ORDER BY dbo.EventLog.EventIdDay DESC, dbo.EventLog.EventIdFraction DESC

if (@@ERROR <> 0)
	set @iReturnVal = -1

return @iReturnVal

GO

