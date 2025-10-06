
----------------------------------------------------------------------
-- AmsSp_AL_ProcessNotification_1
--
-- Process the notification.
--
-- Inputs -
--  @nNotifyType int - the type of notification.
--  @sNotifyData nvarchar(1024) - notification data.
--
-- Outputs -
--  nALUpdated - AL has been updated
--  nDMLUpdated - DML has been updated
--  nPSALUpdated - PlantServer AlertMonitor flag has been updated
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer - 11/26/2007
--
CREATE PROCEDURE AmsSp_AL_ProcessNotification_1
@nNotifyType int,
@sNotifyData nvarchar(1024),
@nALUpdated int output,
@nDMLUpdated int output,
@nPSAMUpdated int output
AS
declare @nReturn int
set @nReturn = 0
set @nALUpdated = 0
set @nDMLUpdated = 0
set @nPSAMUpdated = 0

-- SCR AOEP00027934 added notify Q entries to kick AL, DML and PSAM updates without doing database accesses
--print 'AmsSp_AL_ProcessNotification_1:: processing notifyType- ' + cast(@nNotifyType as nvarchar(10))

if @nNotifyType = 1
begin
	exec @nReturn = AmsSp_AL_ProcessNotifyEventLogInsert_1 @sNotifyData, @nALUpdated output, @nDMLUpdated output, @nPSAMUpdated output
end
else if @nNotifyType = 2
begin
	exec @nReturn = AmsSp_AL_ProcessNotifyAlertLogInsert_1 @sNotifyData, @nALUpdated output, @nDMLUpdated output, @nPSAMUpdated output
end
else if @nNotifyType = 3
begin
	exec @nReturn = AmsSp_AL_ProcessNotifyDeviceMonitorListDelete_1 @sNotifyData, @nALUpdated output, @nDMLUpdated output, @nPSAMUpdated output
end
else if @nNotifyType = 4
begin
	exec @nReturn = AmsSp_AL_ProcessNotifyDeviceMonitorListItemUpdate_1 @sNotifyData, @nALUpdated output, @nDMLUpdated output, @nPSAMUpdated output
end
else if @nNotifyType = 5
begin
	exec @nReturn = AmsSp_AL_ProcessNotifyRenameDevice_1 @sNotifyData, @nALUpdated output, @nDMLUpdated output, @nPSAMUpdated output
end
else if @nNotifyType = 6
begin
	set @nALUpdated = 1
end
else if @nNotifyType = 7
begin
	set @nDMLUpdated = 1
end
else if @nNotifyType = 8
begin
	set @nPSAMUpdated = 1
end
else
begin
	-- invalid notifyType !!!
	print 'Invalid notifyType=' + cast (@nNotifyType as nvarchar(10))
	set @nReturn = -1
end

return @nReturn

GO

