----------------------------------------------------------------------
-- AmsSp_Operation_RenameDevice_1
--
-- Process the rename device operation.
--
-- Note: all this procedure does is verify that the device (the blockKey)
-- is in the polling list (i.e. scanlist) and if it is, it takes its associated
-- plantServerKey and publishes a rename-device notification.
--
-- Inputs -
--  @nBlockKey int.
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- Joe Fisher 10/27/2004
--
CREATE  PROCEDURE AmsSp_Operation_RenameDevice_1
@nBlockKey int
AS
set nocount on
declare @nReturn int
set @nReturn = 0

-- check to see if the device is in the pollList.
-- SCR AOEP00025853 - with Puma, if a device is in the DeviceMonitorList, it should kick
-- the alert monitor windows.  AmsSp_DevBlk_GetAlertMonitorStatus_1 can return a value of '3'
-- which means that we the device is in the monitor list but monitoring is disabled
-- this is still ok because some other machine might be monitoring the alerts and 
-- will want to be updated because the device has been renamed 
declare @sVal nvarchar(1024)
exec @nReturn = AmsSp_DevBlk_GetAlertMonitorStatus_1 @nBlockKey, @sVal output
if (@nReturn <> 0)
begin
	return -1	-- we had an error.
end
if ((@sVal <> '2') and (@sVal <> '3'))
begin
	return 0	-- not in the poll-list
end

-- get the plantServerKey
declare @nPlantServerKey int
exec @nReturn = AmsSp_DevBlk_GetPlantServerKey_1 @nBlockKey, @nPlantServerKey output
if (@nReturn <> 0)
begin
	return -1	-- not associated to a plantServer; error because we are in the polllist.
end

-- send the rename-device notification.
exec @nReturn = AmsSp_NotifyQ_PushRenameDevice_1 @nPlantServerKey, @nBlockKey
if (@nReturn <> 0)
begin
	return -1	-- not able to publish notification.
end

return @nReturn

GO

