
----------------------------------------------------------------------
-- AmsSp_AL_ProcessNotifyRenameDevice_1
--
-- Process the rename device notification.
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
CREATE  PROCEDURE AmsSp_AL_ProcessNotifyRenameDevice_1
@sNotifyData nvarchar(1024),
@nALUpdated int output,
@nDMLUpdated int output,
@nPSAMUpdated int output
AS

set nocount on

declare @nReturn int
set @nReturn = 0

set @nALUpdated = 0
set @nDMLUpdated = 0
set @nPSAMUpdated = 0

-- breakout the device / plantServer info from the notifyData.
declare @nBlockKey int
declare @nPlantServerKey int

exec @nReturn = AmsSp_NotifyData_CrackRenameDevice_1 @sNotifyData,
														@nBlockKey output,
													    @nPlantServerKey output
if (@nReturn <> 0)
begin
	return -1
end

/*
print 'AmsSp_AL_ProcessNotifyRenameDevice_1 ...'
print 'BlockKey=' + cast(@nBlockKey as nvarchar(10))
*/

-- the update policy for renaming a device is this --
--  1) update the al-tracking indicating that an update has occurred for this plantServer.
--  2) notify of an update if it is in the DeviceMonitorList
--

select * from DeviceMonitorList where BlockKey = @nBlockKey

if (@@rowcount = 1)
begin
	set @nDMLUpdated = 1
end

select * from AlertList where BlockKey = @nBlockKey
-- SCR AOEP00025853 - if there happens to be more than one alert in the alert
-- list for this device during a rename, it won't kick any alert monitors.
-- changed the conditonal to allow more than one row to kick
if (@@rowcount > 0)
begin
	set @nALUpdated = 1
end

declare @dt datetime
set @dt = GETUTCDATE()
exec @nReturn = AmsSp_ALTrack_ALUpdated_1 @dt

return @nReturn

GO

