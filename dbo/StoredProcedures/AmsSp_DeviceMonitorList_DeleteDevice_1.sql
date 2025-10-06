
-----------------------------------------------------------------------
-- AmsSp_DeviceMonitorList_DeleteDevice_1
--
--	Delete the device's DeviceMonitorList info.
--	The device identification is based on currently assigned AmsTag.
--
--	The device identification is based on the boolean input parameter
--	@bIdByAmsTag - non-zero = id is by AmsTag, zero = id is by DeviceInfo.
--
--
--  Note: if the device is not found then we error.
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
--	@sPsName - the device's associated plantServer name.
--
-- Recordset output --
--
-- Returns -
--	0 - successful.
--	-1 - general error.
--	-2 - device not found in scanList.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_DeviceMonitorList_DeleteDevice_1
@bIdByAmsTag int,
@sAmsTag nvarchar(255),
@sMfrId nvarchar(255),
@sProtocol nvarchar(255),
@sDeviceTypeCode nvarchar(255),
@sDeviceRevisionCode nvarchar(255),
@sSerialNumber nvarchar(255),
@sPsName nvarchar(255) output
AS

set nocount on
declare @nReturn int
set @nReturn = 0

set @sPsName = ''

declare @nBlockKey int
set @nBlockKey = -9988

declare @sDeviceIdAsString nvarchar(255)

-- make sure the device is in the scanlist.
if (@bIdByAmsTag <> 0)
begin
	-- identify the device with the AmsTag
	set @sDeviceIdAsString = 'Id by AmsTag- ' + @sAmsTag
	--print 'AmsSp_ScanList_DeleteByDevice_1:: ' + @sDeviceIdAsString
	select  @nBlockKey = isnull(BlockKey, -9988),
			@sPsName = isnull(PlantServerId, ' ')
	from AmsVw_AlertMonitorBlockInfo with (nolock) where AmsTag = @sAmsTag
end
else
begin
	-- identify device with deviceInfo.
	set @sDeviceIdAsString = 'Id by DeviceInfo- ' + @sMfrId + '!' + @sProtocol + '!' + @sDeviceTypeCode + '!' + @sDeviceRevisionCode + '!' + @sSerialNumber
	--print 'AmsSp_ScanList_DeleteByDevice_1:: ' + @sDeviceIdAsString
	select  @nBlockKey = isnull(BlockKey, -9988),
			@sPsName = isnull(PlantServerId, ' ')
	from AmsVw_AlertMonitorBlockInfo with (nolock) where (MfrId = @sMfrId) and
										(Protocol = @sProtocol) and
										(DeviceTypeCode = @sDeviceTypeCode) and
										(DeviceRevisionCode = @sDeviceRevisionCode) and
										(SerialNumber = @sSerialNumber)
end

if (@nBlockKey <> -9988)
begin
	-- we have the device in the devicemonitorlist.
	-- delete it.
	-- and delete the filters
	delete from alertfilterfordevice with (rowlock) where BlockKey = @nBlockKey
	if (@@error <> 0)
	begin
		print 'AmsSp_DeviceMonitorList_DeleteDevice_1:: ERROR- unable to delete device(' + @sDeviceIdAsString + ') from alertfilterfordevice; error=' + cast(@@error as nvarchar(20))
		return -1
	end

	delete from devicemonitorlist with (rowlock) where BlockKey = @nBlockKey
	if (@@error <> 0)
	begin
		print 'AmsSp_DeviceMonitorList_DeleteDevice_1:: ERROR- unable to delete device(' + @sDeviceIdAsString + ') from devicemonitorlist; error=' + cast(@@error as nvarchar(20))
		return -1
	end

	-- do not delete from the alert list, the NotifyQ - ProcessNotifyDeviceMonitorListDelete will take care of this
	-- because then it will get an accurate count of alerts that were deleted and will be able to allow the 
	-- Connection Server to kick the AlertMonitor GUI's more efficiently.

	-- notify the AL that we have modified a DeviceMonitorListItem.
	exec AmsSp_NotifyQ_PushDeviceMonitorListDelete_1 @nBlockKey
end
else
begin
	-- we did not find the device in the scanList!
	print 'AmsSp_DeviceMonitorList_DeleteDevice_1:: Device not in DeviceMonitorList- ' + @sDeviceIdAsString
	return -2
end

return 0 -- we are successful if we get here.

GO

