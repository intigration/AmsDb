
-----------------------------------------------------------------------
-- AmsSp_DeviceMonitorList_UpdateDevice_1
--
--	Update the device DeviceMonitorList info.
--	If the device is not found in the DeviceMonitorList it is added.
--
--	The device identification is based on the boolean input parameter
--	@bIdByAmsTag - non-zero = id is by AmsTag, zero = id is by DeviceInfo.
--
--
--  Note: the Frequency is entered as minutes but is stored in the
--	the devicemonitorlist in milliseconds.
--
--  Note: if the device is not found then we error.
--
--  Note: if the device is not currently assigned then we error.
--
-- Inputs --
--  @dtStartTime - how far back in time to begin the search for activeAlert candidates.
--  @bIdByAmsTag - non-zero the device id is the AmsTag else the DeviceInfo.
--	@sAmsTag - the device's current AmsTag assignment.
--	@sFrequency - supplied in minutes.
--	@sMonitorGroup - the scan grouping this device belongs to.
--	@sDVMEnabled - '1' or '0'
--
--  NOTE: device specific filtering is done with a different call
--
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
--	none
--
-- Returns -
--	0 - successful.
--	-1 - general error.
--	-2 - device not found.
--	-3 - device not currently assigned.
--  -4 - Failed on getting conventional device Major/Minor category.
--  -5 - invalid device type.
--  -6 - invalid Frequency.
--  -7 - invalid MonitorGroup.
--
-- James Kramer 11/26/2007
-- Nghy Hong 2/21/2012	- Add NonDD Conventinal protocol to the filter 
--
CREATE PROCEDURE AmsSp_DeviceMonitorList_UpdateDevice_1
@dtStartTime datetime,
@bIdByAmsTag int,
@sAmsTag nvarchar(255),
@sFrequency nvarchar(10),
@sMonitorGroup nvarchar(10),
@sDVMEnabled nvarchar(10),
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
set @nBlockKey = -99
declare @nAssignStatus int
declare @nPlantServerKey int
set @nAssignStatus = -99
set @nPlantServerKey = -99

declare @sDeviceIdAsString nvarchar(255)

-- make sure the device is in the system and is currently assigned.
if (@bIdByAmsTag <> 0)
begin
	-- identify the device with the AmsTag
	set @sDeviceIdAsString = 'Id by AmsTag- ' + @sAmsTag
	--print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: ' + @sDeviceIdAsString
	select  @nBlockKey = isnull(BlockKey, -99),
			@nAssignStatus = isnull(DispositionId, -99),
			@nPlantServerKey = isnull(PlantServerKey, -99),
			@sPsName = isnull(PlantServerId, ' '),
			@sProtocol = isnull(Protocol, '')
	from AmsVw_DeviceTagLocation with (nolock) where AmsTag = @sAmsTag
end
else
begin
	-- identify device with deviceInfo.
	set @sDeviceIdAsString = 'Id by DeviceInfo- ' + @sMfrId + '!' + @sProtocol + '!' + @sDeviceTypeCode + '!' + @sDeviceRevisionCode + '!' + @sSerialNumber
	--print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: ' + @sDeviceIdAsString
	select  @nBlockKey = isnull(BlockKey, -99),
			@nAssignStatus = isnull(DispositionId, -99),
			@nPlantServerKey = isnull(PlantServerKey, -99),
			@sPsName = isnull(PlantServerId, ' ')
	from AmsVw_DeviceTagLocation with (nolock) where (MfrId = @sMfrId) and
										(Protocol = @sProtocol) and
										(DeviceTypeCode = @sDeviceTypeCode) and
										(DeviceRevisionCode = @sDeviceRevisionCode) and
										(SerialNumber = @sSerialNumber)
end

if (@nBlockKey = -99)
begin
	-- we did not find the device in the system!
	print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: Did not find device-' + @sDeviceIdAsString + ' in the system!!'
	return -2
end

if (@nAssignStatus <> 1)
begin
	print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: device(' + @sDeviceIdAsString + ') is not currently assigned!'
	return -3
end

-- if this is conventional device, we only accept NonDD conventional 
declare @MajorCatId int, @MinorCatId int
if (@sProtocol = 'CONVENTIONAL')
begin
	exec @nReturn = AmsSp_GetDeviceCategory_2 @sAmsTag, @MajorCatId output, @MinorCatId output
	if (@nReturn = 0)
	begin
		if (@MinorCatId <> 83) -- 83 = NonDD
		begin
			print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: Device(' + @sDeviceIdAsString + ') is invalid device type!'
			return -5
		end
	end
	else
	begin
		print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: Failed on getting Conventional device(' + @sDeviceIdAsString + ') Major/Minor category!'
		return -4
	end
end

-- we are going to ignore some items sent down when a FF device.
if (@sProtocol = 'FF' or 
    @sProtocol = 'PROFIBUS-DP' or 
    @sProtocol = 'PROFIBUS-PA' or
	@sProtocol = 'CONVENTIONAL')
begin
	set @sDVMEnabled = '0'

	if (@sProtocol = 'FF')
	begin
		set @sFrequency = '0'
	end
end

-- we can only accept certain device types.
if ((@sProtocol <> 'FF') and 
    (@sProtocol <> 'HART') and 
    (@sProtocol <> 'PROFIBUS-DP') and
    (@sProtocol <> 'PROFIBUS-PA') and
    (@sProtocol <> 'CONVENTIONAL'))
begin
	print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: Device(' + @sDeviceIdAsString + ') is invalid device type!'
	return -5
end

-- verify that user has presented us with some valid data here.
declare @nMonitorGroup int
declare @nFrequency int
declare @nDVMEnabled bit

-- need to do some conversions here.
set @nMonitorGroup = cast(@sMonitorGroup as int)
set @nFrequency = cast(@sFrequency as int) -- still in minutes
set @nDVMEnabled = cast(@sDVMEnabled as bit)
-- setup our range check values
declare @MIN_MONITOR_GROUP int
declare @MAX_MONITOR_GROUP int
declare @MIN_FREQUENCY int -- min. minutes
declare @MAX_FREQUENCY int -- max. minutes in 7days, 23hrs, 59min
set @MIN_MONITOR_GROUP = 1
set @MAX_MONITOR_GROUP = 999
set @MIN_FREQUENCY = 1 -- min. minutes
set @MAX_FREQUENCY = 11519 -- max. minutes in 7days, 23hrs, 59min

if (@sProtocol = 'HART' or 
    @sProtocol = 'PROFIBUS-DP' or 
	@sProtocol = 'PROFIBUS-PA')
begin
	if (( @nMonitorGroup >= @MIN_MONITOR_GROUP) and (@nMonitorGroup <= @MAX_MONITOR_GROUP))
	begin
		if ((@nFrequency >= @MIN_FREQUENCY) and (@nFrequency <= @MAX_FREQUENCY))
		begin
			set @nReturn = 0
		end
		else
		begin
			print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: Device(' + @sDeviceIdAsString + ') Frequency out of range!'
			return -6
		end
	end
	else
	begin
		print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: Device(' + @sDeviceIdAsString + ') MonitorGroup out of range!'
		return -7
	end
end

-- convert our Frequency to milliseconds.
set @nFrequency = @nFrequency * 60000 -- minutes converted to milliseconds.

-- if device not in DeviceMonitorList go ahead and add it.
declare @bNewDevice bit
set @bNewDevice = 0

-- check to see if the device is in the DeviceMonitorList.
-- this will help us determine if we need to do a insert (new) or a modify.
if (@bIdByAmsTag <> 0)
begin
	-- identify device with AmsTag
	if not exists (select * from AmsVw_AlertMonitorBlockInfo where AmsTag = @sAmsTag)
	begin
		set @bNewDevice = 1
	end
end
else
begin
	-- identify device with deviceInfo.
	if not exists (select * from AmsVw_AlertMonitorBlockInfo where (MfrId = @sMfrId) and
										(Protocol = @sProtocol) and
										(DeviceTypeCode = @sDeviceTypeCode) and
										(DeviceRevisionCode = @sDeviceRevisionCode) and
										(SerialNumber = @sSerialNumber))
	begin
		set @bNewDevice = 1
	end
end

if (@bNewDevice <> 0)
begin
	-- we do not have the device in the DeviceMonitorList.
	insert into devicemonitorlist with (rowlock) (BlockKey, MonitorGroup, Frequency, DVMEnabled)
		values (@nBlockKey, @nMonitorGroup, @nFrequency, @nDVMEnabled)
	if (@@error <> 0)
	begin
		print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: Unable to add Device(' + @sDeviceIdAsString + ') into DeviceMonitorList!!'
		return -1
	end
	set @bNewDevice = 1

	exec AmsSP_AL_CreateFiltersForDevice_1 @nBlockKey
end
else
begin
	update devicemonitorlist with (rowlock) set
		MonitorGroup = @nMonitorGroup,
		Frequency = @nFrequency,
		DVMEnabled = @nDVMEnabled
	where BlockKey = @nBlockKey

	if (@@error <> 0)
	begin
		print 'AmsSp_DeviceMonitorList_UpdateDevice_1:: Update error here on Device(' + @sDeviceIdAsString + '), error=' + cast(@@error as nvarchar(20))
		return -1
	end
end

-- notify the AL that we have modified the DeviceMonitorList
if (@nReturn = 0)
begin
	exec AmsSp_NotifyQ_PushDeviceMonitorListItemUpdate_1 @nBlockKey, @dtStartTime
end

return 0 -- we were successful if we reached this point.

GO

