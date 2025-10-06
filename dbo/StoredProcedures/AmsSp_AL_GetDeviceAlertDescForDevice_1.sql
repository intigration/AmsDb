
-----------------------------------------------------------------------
-- AmsSp_AL_GetDeviceAlertDescForDevice_1
--
--	returns a list of the filters for a given device - this procedure does not go to the device
--  monitor list in order to retrieve the filters
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
-- James Kramer 1/30/2008
--
CREATE PROCEDURE AmsSp_AL_GetDeviceAlertDescForDevice_1
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

-- make sure the device is in the system and is currently assigned.
if (@bIdByAmsTag <> 0)
begin
	-- identify the device with the AmsTag
	select  @nBlockKey = isnull(BlockKey, -99)
	from AmsVw_BlockTags with (nolock) where AmsTag = @sAmsTag
end
else
begin
	-- identify device with deviceInfo.
	select  @nBlockKey = isnull(BlockKey, -99)
	from AmsVw_BlockTags with (nolock) where (MfrId = @sMfrId) and
										(Protocol = @sProtocol) and
										(DeviceTypeCode = @sDeviceTypeCode) and
										(DeviceRevisionCode = @sDeviceRevisionCode) and
										(SerialNumber = @sSerialNumber)
end

if (@nBlockKey = -99)
begin
	return -1
end

select AlertId, DeviceAlertDesc.AlertTypeId, Uid as AlertTypeUid, Description, Enabled = 1
from DeviceAlertDesc INNER JOIN
	 Devices ON DeviceAlertDesc.AmsDevRevId = Devices.AmsDevRevId INNER JOIN
	 Blocks ON Devices.DeviceKey = Blocks.DeviceKey INNER JOIN
	 AlertTypes ON DeviceAlertDesc.AlertTypeId = AlertTypes.AlertTypeId
where Blocks.BlockKey = @nBlockKey

return @nReturn

GO

