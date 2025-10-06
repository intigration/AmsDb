
-----------------------------------------------------------------------
-- AmsSp_GetDevTypeInfoByFFId_1
--
-- Get device type info by FF deviceId.
--
-- Inputs -
--	@sIdentifier	nvarchar(256)
--
-- Outputs -
--	ManufacturerName
--	ProtocolName
--	MfrId
--	DeviceTypeName
--	DeviceTypeCode
--	DeviceRevisionName
--	DeviceRevisionCode
--
-- Returns -
--	returns the number of rows in the resultset.
--      -1 - device type info not found.
--	-2 - general error.
--
-- Joe Fisher, 08/13/2003
--
CREATE  PROCEDURE AmsSp_GetDevTypeInfoByFFId_1
@sIdentifier	nvarchar(256),
@sOutManufacturer		nvarchar(255) output,
@sOutProtocolName		nvarchar(255) output,
@nOutMfrId			int output,
@sOutDeviceTypeName	nvarchar(255) output,
@nOutDeviceTypeCode	int output,
@sOutDeviceRevisionName nvarchar(255) output,
@nOutDeviceRevisionCode int output
AS
DECLARE @sErrorMsg nvarchar(256)
DECLARE @iReturnVal int
set @iReturnVal = 0

set nocount on

-- go ahead and select based on supplied parameters

SELECT     @sOutManufacturer = dbo.Manufacturers.Name,
			@nOutMfrId = dbo.MfrProtocols.MfrId,
			@sOutProtocolName = dbo.DeviceProtocols.Name, 
            @sOutDeviceTypeName = dbo.DeviceTypes.Name,
			@nOutDeviceTypeCode = dbo.DeviceTypes.DeviceType, 
            @sOutDeviceRevisionName = dbo.DeviceRevisions.Name,
			@nOutDeviceRevisionCode = dbo.DeviceRevisions.DeviceRevision
FROM         dbo.Manufacturers with (nolock) INNER JOIN
          dbo.MfrProtocols with (nolock) ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
          dbo.DeviceProtocols with (nolock) ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
          dbo.DeviceTypes with (nolock) ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
          dbo.DeviceRevisions with (nolock) ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId INNER JOIN
          dbo.Devices with (nolock) ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId
WHERE     (dbo.Devices.Identifier = @sIdentifier) AND 
		(dbo.DeviceProtocols.Name = 'FF')

if (@@ROWCOUNT = 0)
begin
	set @iReturnVal = -1
end

return @iReturnVal

errorHandler:
PRINT 'AmsSp_GetDevTypeInfoByFFId_1: ' + @sErrorMsg
RETURN -2

GO

