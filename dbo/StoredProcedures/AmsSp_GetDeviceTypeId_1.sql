----------------------------------------------------------------------
-- AmsSp_GetDeviceTypeName_1
--
-- Get device type ID for the given device type name
--
-- Inputs -
--	@sDeviceTypeName nvarchar(255)	Device type name
-- Output -
--	@sDeviceTypeId nvarchar(255)	Device type ID
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--  -2 - Device type name not found in database
--
-- Peter Nguyen 6/25/2012
--
CREATE PROCEDURE AmsSp_GetDeviceTypeId_1
@sDeviceTypeName nvarchar(255),
@sDeviceTypeId nvarchar(255) output
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY

	set @sDeviceTypeId = N'';
	select @sDeviceTypeId = DeviceType from DeviceTypes where DeviceTypes.Name = @sDeviceTypeName
	if (@sDeviceTypeId = N'')
		set @nReturn = -2;

END TRY
BEGIN CATCH
	set @nReturn = -1;
END CATCH

RETURN @nReturn;

GO

