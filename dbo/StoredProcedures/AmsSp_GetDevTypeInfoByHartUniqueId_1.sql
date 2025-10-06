
-----------------------------------------------------------------------
-- AmsSp_GetDevTypeInfoByHartUniqueId_1
--
-- Get device type info by HART unique id.
-- Note: the device must be present for this to work!
--
-- Inputs -
--	@nMfrId				int
--	@nDeviceTypeCode 	int
--	@nProtocolRev		int
--	@sIdentifier		nvarchar(255)
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
-- Joe Fisher, 10/14/2003
--
CREATE  PROCEDURE AmsSp_GetDevTypeInfoByHartUniqueId_1
@nMfrId				int,
@nDeviceTypeCode 	int,
@nDeviceRevisionCode int,
@nProtocolRev		int,
@sIdentifier		nvarchar(255),
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
WHERE     (dbo.MfrProtocols.MfrId = @nMfrId) AND
		  (dbo.DeviceTypes.DeviceType = @nDeviceTypeCode) AND
		  (dbo.DeviceRevisions.DeviceRevision = @nDeviceRevisionCode) AND
		  (dbo.Devices.ProtocolRevision = @nProtocolRev) AND 
          (dbo.Devices.Identifier = @sIdentifier) AND
		  (dbo.DeviceProtocols.Name = 'HART')

if (@@ROWCOUNT = 0)
begin
	set @iReturnVal = -1
end

return @iReturnVal

errorHandler:
PRINT 'AmsSp_GetDevTypeInfoByHartUniqueId_1: ' + @sErrorMsg
RETURN -2

GO

