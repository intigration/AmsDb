
----------------------------------------------------------------------
-- AmsSp_AL_ProcessNotifyDeviceMonitorListItemUpdate_1
--
-- Process the DeviceMonitorListItem update notification.
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
CREATE  PROCEDURE AmsSp_AL_ProcessNotifyDeviceMonitorListItemUpdate_1
@sNotifyData nvarchar(1024),
@nALUpdated int output,
@nDMLUpdated int output,
@nPSAMUpdated int output
AS

set nocount on

declare @nReturn int
set @nReturn = 0

-- this currently gets called when the device got updated (AmsSp_DeviceMonitorList_UpdateDevice_1)
-- breakout the event info from the notifyData.
declare @nBlockKey int
declare @dtStartTime datetime

exec @nReturn = AmsSp_NotifyData_CrackDeviceMonitorListItemUpdate_1 @sNotifyData,
														@nBlockKey output,
														@dtStartTime output

if (@nReturn <> 0)
begin
	return @nReturn
end
/*
print 'AmsSp_AL_ProcessNotifyDeviceMonitorListItemUpdate_1 ...'
print 'BlockKey=' + cast(@nBlockKey as nvarchar(10))
*/

-- the update policy for a device is this --
--  1) do nothing - do not delete any items from the alert list
--
-- OK now go ahead and ie. refresh the al for this device.
declare @nAlertsAdded int
set @nAlertsAdded = 0
exec AmsSp_AL_InitializeForDevice_1 @nBlockKey, @dtStartTime, @nAlertsAdded output

-- only update the al-tracker if we deleted from the al and not added to.
-- reason being that the addedTo process will have already updated the al-tracker.
--print 'AmsSp_AL_ProcessNotifyDeviceMonitorListItemUpdate_1: alerts updated for device(' + cast(@nBlockKey as nvarchar(10)) + ')'
declare @dt datetime
set @dt = GETUTCDATE()
exec AmsSp_ALTrack_ALDeviceUpdated_1 @nBlockKey, @dt, 2
--print 'AmsSp_AL_ProcessNotifyDeviceMonitorListItemUpdate_1: no alerts found for device(' + cast(@nBlockKey as nvarchar(10)) + ')'

set @nALUpdated = 0
set @nDMLUpdated = 1 -- well the device was either added or updated, in which case the DML is probably out of date
set @nPSAMUpdated = 0

declare @nCnt int

select @nCnt = count (*) from 
	alertfilterfordevice inner join
	alertlist on alertfilterfordevice.BlockKey = alertlist.BlockKey 
where alertfilterfordevice.BlockKey = @nBlockKey and Enabled = 'True'

if (@nCnt > 0)
begin
	set @nALUpdated = 1
end

return @nReturn

GO

