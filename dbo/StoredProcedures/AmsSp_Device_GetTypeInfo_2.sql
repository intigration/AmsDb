
-----------------------------------------------------------------------
-- AmsSp_Device_GetTypeInfo_2
--
-- Get device type info.
--
-- Inputs -
--	@strDeviceID nvarchar(256)
--		the device identifier.
--

-- Outputs --
--	AmsTag
--	Manufacturer
--	Protocol
--  MfrId
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber
--	ProtocolRevision
--
-- Returns -
--	  0 - successful.
--    -1 - general error.
--
-- Nghy Hong, 09/16/2009
--
CREATE  PROCEDURE AmsSp_Device_GetTypeInfo_2
@strDeviceID nvarchar(256)
AS
DECLARE @iReturnVal int;
SET @iReturnVal = 0;
SET NOCOUNT ON;

BEGIN TRY

	SELECT AmsTag, Manufacturer, Protocol, MfrId, DeviceTypeCode, DeviceTypeName, 
		   DeviceRevisionCode, DeviceRevisionName, SerialNumber, ProtocolRevision
	FROM   AmsVw_DeviceTags
	WHERE  (SerialNumber = @strDeviceID)

END TRY
BEGIN CATCH
	SET @iReturnVal = -1;
END CATCH;

RETURN @iReturnVal;

GO

