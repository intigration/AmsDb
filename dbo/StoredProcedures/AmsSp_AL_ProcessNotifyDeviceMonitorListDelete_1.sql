
----------------------------------------------------------------------
-- AmsSp_AL_ProcessNotifyDeviceMonitorListDelete_1
--
-- Process the eventLog insert notification.
--
-- Inputs -
--  @sNotifyData nvarchar(1024) - notification data.
--
-- Outputs -
-- @nALUpdated
-- @nDMLUpdated
-- @nPSAMUpdated
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_AL_ProcessNotifyDeviceMonitorListDelete_1
@sNotifyData nvarchar(1024),
@nALUpdated int output,
@nDMLUpdated int output,
@nPSAMUpdated int output
AS

set nocount on

declare @nReturn int
set @nReturn = 0

-- this currently gets called when the device is deleted
-- in that event, we will assume that the DML needs to be flagged that things have changed
set @nALUpdated = 0
set @nDMLUpdated = 1
set @nPSAMUpdated = 0

-- breakout the event info from the notifyData.
declare @nBlockKey int

exec @nReturn = AmsSp_NotifyData_CrackDeviceMonitorListDelete_1 @sNotifyData,
														@nBlockKey output

if (@nReturn <> 0)
begin
	return @nReturn
end
/*
print 'AmsSp_AL_ProcessNotifyDeviceMonitorListDelete_1 ...'
print 'BlockKey=' + cast(@nBlockKey as nvarchar(10))
*/

-- device is being removed from the DeviceMonitorList.
-- remove any reference to this device from the AlertList
delete from AlertList where BlockKey = @nBlockKey
if (@@rowcount > 0)
begin
--print 'AmsSp_AL_ProcessNotifyDeviceMonitorListDelete_1: alerts removed for device(' + cast(@nBlockKey as nvarchar(10)) + ')'
	declare @dt datetime
	set @dt = GETUTCDATE()
	exec AmsSp_ALTrack_ALDeviceUpdated_1 @nBlockKey, @dt, 2

	set @nALUpdated = 1
end
else
begin
--print 'AmsSp_AL_ProcessNotifyDeviceMonitorListDelete_1: no alerts found for device(' + cast(@nBlockKey as nvarchar(10)) + ')'
	declare @n int -- dummy so we don't end up with an empty begin-end.
end

return @nReturn

GO

