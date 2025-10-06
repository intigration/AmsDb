-----------------------------------------------------------------------
-- AmsSp_GetDevTypeInfoByPBId_1
--
-- Get device type info by PROFIBUS deviceId.
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
--		-2 - general error.
--
-- Nghy Hong, 10/06/2009
--
CREATE PROCEDURE AmsSp_GetDevTypeInfoByPBId_1
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

set nocount on;

Begin Try

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
			  ((dbo.DeviceProtocols.Name = 'PROFIBUS-DP') or
			   (dbo.DeviceProtocols.Name = 'PROFIBUS-PA'))

	if (@@ROWCOUNT = 0)
	begin
		set @iReturnVal = -1;
	end

End try
Begin Catch
	set @iReturnVal = -2;
	PRINT 'AmsSp_GetDevTypeInfoByPBId_1: ' + ERROR_MESSAGE();
End Catch;

return @iReturnVal

GO

