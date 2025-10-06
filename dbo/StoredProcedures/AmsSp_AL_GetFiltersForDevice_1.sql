
-----------------------------------------------------------------------
-- AmsSp_AL_GetFiltersForDevice_1
--
--	returns a list of the filters for a given device
--
-- Inputs --
--  @bIdByAmsTag - non-zero the device id is the AmsTag else the DeviceInfo.
--	@sAmsTag - the device's current AmsTag assignment.
---- deviceInfo --
--  @sMfrId - Manufacturer identifier.
--	@sProtocol - protocol
--  @sDeviceTypeCode - device type code.
--	@sDeviceRevisionCode - device revision code.
--	@sSerialNumber - device serial number.
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
CREATE PROCEDURE AmsSp_AL_GetFiltersForDevice_1
@bIdByAmsTag int,
@sAmsTag nvarchar(255),
@sMfrId nvarchar(255),
@sProtocol nvarchar(255),
@sDeviceTypeCode nvarchar(255),
@sDeviceRevisionCode nvarchar(255),
@sSerialNumber nvarchar(255)
AS

set nocount on
declare @nReturn int
set @nReturn = 0

declare @nBlockKey int

set @nBlockKey = -99

-- make sure the device is in the devicemonitorlist.
if (@bIdByAmsTag <> 0)
begin
	select  @nBlockKey = isnull(BlockKey, -99)
	from AmsVw_AlertMonitorBlockInfo with (nolock) where AmsTag = @sAmsTag
end
else
begin
	select  @nBlockKey = isnull(BlockKey, -99)
	from AmsVw_AlertMonitorBlockInfo with (nolock) where (MfrId = @sMfrId) and
										(Protocol = @sProtocol) and
										(DeviceTypeCode = @sDeviceTypeCode) and
										(DeviceRevisionCode = @sDeviceRevisionCode) and
										(SerialNumber = @sSerialNumber)
end

if (@nBlockKey = -99)
begin
	return -1
end

select AlertId, Enabled, AlertTypeId, Description
from DeviceAlertDesc INNER JOIN
	 AlertFilterForDevice ON AlertFilterForDevice.AlertDescId = DeviceAlertDesc.AlertDescId INNER JOIN
	 DeviceMonitorList ON DeviceMonitorList.BlockKey = AlertFilterForDevice.BlockKey
where DeviceMonitorList.BlockKey = @nBlockKey

return @nReturn

GO

