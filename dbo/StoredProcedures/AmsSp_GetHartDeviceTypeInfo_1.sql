
-----------------------------------------------------------------------
-- AmsSp_GetHartDeviceTypeInfo_1
--
-- Get the deviceTypeName and deviceRevisionName for a HART device type
-- based on manufacturer name, deviceTypeCode, and deviceRevisionCode.
--
-- Inputs -
--	manufactuerName
--	deviceTypeCode
--	deviceRevisionCode
--
-- Outputs -
--	deviceTypeName
--	deviceRevisionName
--
-- Returns -
--	0 - success.
--	-1 - not found.
--	-2 - error.
--
-- Joe Fisher, 1/5/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetHartDeviceTypeInfo_1
@sMfrName as nvarchar(255),
@nDeviceTypeCode as int,
@nDeviceRevisionCode as int,
@sDeviceTypeName as nvarchar(255) OUTPUT,
@sDeviceRevisionName as nvarchar(255)OUTPUT
AS
declare @iReturnVal int
set @iReturnVal = 0
declare @sProtocolName nvarchar(255)
set @sProtocolName = 'HART'

SELECT TOP 1 @sDeviceTypeName = DeviceTypes.Name, @sDeviceRevisionName = DeviceRevisions.Name
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
WHERE (Manufacturers.Name = @sMfrName) AND 
    (DeviceProtocols.Name = @sProtocolName) AND 
    (DeviceTypes.DeviceType = @nDeviceTypeCode) AND 
    (DeviceRevisions.DeviceRevision = @nDeviceRevisionCode)

if (@sDeviceTypeName is NULL)
begin
    -- data not found.
    set @iReturnVal = -1
end

if (@@ERROR <> 0)
    set @iReturnVal = -2

return @iReturnVal

GO

