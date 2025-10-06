
----------------------------------------------------------------------
-- AmsSp_NotifyQ_PushDeviceMonitorListItemUpdate_1
--
-- Update the AL based on a DeviceMonitorListItem update.
--
-- Inputs -
--	@nBlockKey - the device that is being deleted from the DeviceMonitorList.
--	@dtStartTime datetime - where to start in the EventLog building the AL.
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_NotifyQ_PushDeviceMonitorListItemUpdate_1
@nBlockKey int,
@dtStartTime datetime
AS

set nocount on

declare @nReturn int
set @nReturn = 0

declare @nNotifyType int
declare @sNotifyData nvarchar(max)
exec @nReturn = AmsSp_NotifyData_BuildDeviceMonitorListItemUpdate_1 @nBlockKey,
													    @dtStartTime,
														@nNotifyType output,
														@sNotifyData output

-- push the notification onto the queue.
exec @nReturn = AmsSp_NotifyQ_Push_1 @nNotifyType, @sNotifyData
if (@nReturn <> 0) 
begin
	return -1
end

return @nReturn

GO

