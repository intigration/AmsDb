
-----------------------------------------------------------------------
-- AmsSp_AddDeviceAlertDesc_1
--
--	adds the device alert desc into the database - this is currently coming from
--  AddDeviceType->DeviceAlertDescriptorFileReader
--
-- Inputs --
--		@nMfr - mfr id
--		@nDevType - device type
--		@nDevRev - device revision
--		@sProtocol - protocol
--		@sAlertId - alert
--		@sAlertTypeId - severity
--		@sDesc - description of alert
--		@sExtHelp - extended help text
--		@sDDHelp - dd help text
--
-- Outputs --
--
-- Recordset output --
--
-- Returns -
--	0 - successful.
--	-1 - Error
--
-- James Kramer 2/1/2008
--
CREATE PROCEDURE AmsSp_AddDeviceAlertDesc_1
@nMfr int,
@nDevType int,
@nDevRev int,
@sProtocol nvarchar(255),
@sAlertId nvarchar(1024),
@sAlertTypeId nvarchar(255),
@sDesc nvarchar(256),
@sExtHelp nvarchar(4000),
@sDDHelp nvarchar(4000)
AS

set nocount on
declare @nReturn int
set @nReturn = 0

declare @nAmsDevRevId int
declare @nBlockKey int
declare @nAlertDescId int
declare @nAlertTypeId int

set @nAlertTypeId = -1
set @nAmsDevRevId = -99
set @nBlockKey = -99
set @nAlertDescId = -88

-- find AmsDevRevId
if ((@nDevType = -1) and (@nMfr = -1) and (@nDevRev = -1))
begin
	-- in this case, we are requesting the default alerts which is AmsDevRevId = -1
	set @nAmsDevRevId = -1
end
else
begin
	select  @nAmsDevRevId = AmsDevRevId
	from AmsVw_DeviceTypes
	where DeviceTypeCode = @nDevType and MfrId = @nMfr and DeviceRevisionCode = @nDevRev and Protocol = @sProtocol
end

if (@nAmsDevRevId = -99)
begin
	return -1
end

select @nAlertTypeId = AlertTypeId
from AlertTypes
where Uid = @sAlertTypeId

if (@nAlertTypeId = -1)
begin
	return -2
end

select @nAlertDescId = AlertDescId
from DeviceAlertDesc
where AmsDevRevId = @nAmsDevRevId and AlertId = @sAlertId

if (@nAlertDescId <> -88)
begin
	-- this entry exists already, just update the description, alert type, help text, and dd help text
	update DeviceAlertDesc with (rowlock) set Description = @sDesc, AlertTypeId = @nAlertTypeId
	where AlertDescId = @nAlertDescId

	update ExtDeviceAlertDesc with (rowlock) set ExtendedHelpText = @sExtHelp, DDHelpText = @sDDHelp
	where AlertDescId = @nAlertDescId	
end
else
begin
	-- no entry exists, insert a new alert description

	insert into DeviceAlertDesc (AmsDevRevId,AlertId,Description,AlertTypeId) values (@nAmsDevRevId, @sAlertId, @sDesc, @nAlertTypeId)

	insert into ExtDeviceAlertDesc (AlertDescId, ExtendedHelpText, DDHelpText) values (@@identity, @sExtHelp, @sDDHelp);

	-- now check the devices in the device monitor list for this device type, create filters for the devices that match
	WITH SELECT_DEVICE_ALERT_DESC AS
	(
		SELECT DeviceMonitorList.BlockKey, DeviceAlertDesc.AlertDescId, Enabled = 1
		FROM DeviceMonitorList INNER JOIN
             Blocks ON DeviceMonitorList.BlockKey = Blocks.BlockKey INNER JOIN
             Devices ON Blocks.DeviceKey = Devices.DeviceKey INNER JOIN
             DeviceAlertDesc ON Devices.AmsDevRevId = DeviceAlertDesc.AmsDevRevId	
		WHERE DeviceAlertDesc.AmsDevRevId = @nAmsDevRevId and AlertId = @sAlertId	
	) INSERT INTO AlertFilterForDevice SELECT * FROM SELECT_DEVICE_ALERT_DESC

end

return @nReturn

GO

