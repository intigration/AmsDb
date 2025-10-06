
-----------------------------------------------------------------------
-- AmsSp_GetDevBlkBlockKey_1
--
-- Get device-block block key.
--
-- Inputs -
--	Manufacturer.
--	Protocol.
--	DeviceTypeName.
--	DeviceRevisionName.
--	SerialNumber.
--	Block index (defaults to 0).
--
-- Outputs -
--	block key.
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 03/30/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDevBlkBlockKey_1
@sMfrName as nvarchar(255),
@sProtocolName as nvarchar(255),
@sDeviceTypeName as nvarchar(255),
@sDeviceRevisionName as nvarchar(255),
@sSerialNumber as nvarchar(255),
@nBlockIndex as integer,
@nBlockKey as integer OUTPUT
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

SELECT @nBlockKey = dbo.Blocks.BlockKey
FROM dbo.Manufacturers with (nolock) INNER JOIN
    dbo.MfrProtocols with (nolock) ON 
    dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId
     INNER JOIN
    dbo.DeviceProtocols with (nolock) ON 
    dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER
     JOIN
    dbo.DeviceTypes with (nolock) ON 
    dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId
     INNER JOIN
    dbo.DeviceRevisions with (nolock) ON 
    dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId
     INNER JOIN
    dbo.Devices with (nolock) ON 
    dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId
     INNER JOIN
    dbo.Blocks with (nolock) ON 
    dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey
WHERE (dbo.Manufacturers.Name = @sMfrName) AND 
    (dbo.DeviceProtocols.Name = @sProtocolName) AND 
    (dbo.DeviceTypes.Name = @sDeviceTypeName) AND 
    (dbo.DeviceRevisions.Name = @sDeviceRevisionName) AND 
    (dbo.Devices.Identifier = @sSerialNumber) AND 
    (dbo.Blocks.BlockIndex = @nBlockIndex)

if (@@ERROR <> 0)
	set @iReturnVal = -1

return @iReturnVal

GO

