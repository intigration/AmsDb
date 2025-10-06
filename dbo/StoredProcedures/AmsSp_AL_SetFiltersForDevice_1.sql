
-----------------------------------------------------------------------
-- AmsSp_AL_SetFiltersForDevice_1
--
--	sets the filters for a given device
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
--  @sFilters - an XML file containing all the filters
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
CREATE PROCEDURE AmsSp_AL_SetFiltersForDevice_1
@bIdByAmsTag int,
@sAmsTag nvarchar(255),
@sMfrId nvarchar(255),
@sProtocol nvarchar(255),
@sDeviceTypeCode nvarchar(255),
@sDeviceRevisionCode nvarchar(255),
@sSerialNumber nvarchar(255),
@sFilters nvarchar(max)
AS

set nocount on
declare @nReturn int
set @nReturn = 0

--print 'AmsSp_AL_SetFiltersForDevice_1 - ' + @sFilters

declare @nBlockKey int
declare @nAmsDevRevId int
declare @nAlertDescId int

set @nBlockKey = -99
set @nAmsDevRevId = -99
set @nAlertDescId = -99

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

select @nAmsDevRevId = AmsDevRevId
from Devices INNER JOIN
	 Blocks ON Devices.DeviceKey = Blocks.DeviceKey
where Blocks.BlockKey = @nBlockKey

if (@nAmsDevRevId = -99)
begin
	return -1
end

-- now loop through all the alert Id's in the XML and set/clear each enabled bit

if (len(@sFilters) <= 0) return -2

declare @nDone int
declare @nPos int
declare @nEndPos int
declare @sAlertId nvarchar(255)
declare @sEnabled nvarchar(255)

set @nDone = 0
set @nPos = 0

select @nPos = charindex('Alert', @sFilters)
--print '@nPos=' + cast(@nPos as nvarchar(10))

while (@nDone = 0)
begin
	if (@nPos <= 0)
	begin
		set @nDone = 1
		break
	end

	--print 'Start new alert'
	-- element name is '<elementName>'
	set @nPos = @nPos + len('Alert') + len('>')
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	set @nPos = charindex('Id',@sFilters, @nPos)
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	if (@nPos <= 0)
	begin
		set @nDone = 1
		break
	end

	set @nPos = @nPos + len('Id') + len('>')
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	-- element value stops at first '<'
	set @nEndPos = charindex('</', @sFilters, @nPos)
	--print '@nEndPos=' + cast(@nEndPos as nvarchar(10))

	if (@nEndPos <= 0)
	begin
		set @nDone = 1
		break
	end

	-- get the element value
	set @sAlertId = substring(@sFilters, @nPos, @nEndPos - @nPos)

	--print '@sAlertId=' + @sAlertId

	set @nPos = @nEndPos
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	set @nPos = charindex('Enabled',@sFilters, @nPos)
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	if (@nPos <= 0)
	begin
		set @nDone = 1
		break
	end

	set @nPos = @nPos + len('Enabled') + len('>')
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	-- element value stops at first '<'
	set @nEndPos = charindex('</', @sFilters, @nPos)
	--print '@nEndPos=' + cast(@nEndPos as nvarchar(10))

	if (@nEndPos <= 0)
	begin
		set @nDone = 1
		break
	end

	-- get the element value
	set @sEnabled = substring(@sFilters, @nPos, @nEndPos - @nPos)

	--print '@sEnabled=' + @sEnabled

	set @nPos = @nEndPos
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	set @nEndPos = charindex('</', @sFilters, @nPos)
	--print '@nEndPos=' + cast(@nEndPos as nvarchar(10))

	set @nPos = @nEndPos
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	set @nPos = charindex('Alert', @sFilters, @nPos)
	--print '@nPos=' + cast(@nPos as nvarchar(10))

	select @nAlertDescId = AlertDescId from DeviceAlertDesc where AmsDevRevId = @nAmsDevRevId and AlertId = @sAlertId

	if (@@rowcount = 1)
	begin
		--print 'AmsSp_AL_SetFiltersForDevice_1 - AlertDescId = ' + cast(@nAlertDescId as nvarchar(10)) + ', BlockKey = ' + cast(@nBlockKey as nvarchar(255))
		update AlertFilterForDevice
		set Enabled = @sEnabled
		where BlockKey = @nBlockKey and AlertDescId = @nAlertDescId
	end
end

-- all filters are done, we now need to schedule a DeviceMonitorListItemUpdate command to 'kick' anyone about an alert list change
declare @dtStartTime datetime
declare @sGMT nvarchar(256)
set @sGMT = convert(nvarchar, GETUTCDATE(), 121)
set @sGMT = substring(@sGMT, 1, len(@sGMT) - 1) + '0'

set @dtStartTime = cast(@sGMT as datetime)

exec @nReturn = AmsSp_NotifyQ_PushDeviceMonitorListItemUpdate_1 @nBlockKey, @dtStartTime

return @nReturn

GO

