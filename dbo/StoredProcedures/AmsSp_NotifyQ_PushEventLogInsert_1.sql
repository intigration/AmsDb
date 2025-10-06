----------------------------------------------------------------------
-- AmsSp_NotifyQ_PushEventLogInsert_1
--
-- Add a eventLog insert notification to the notifyQ table.
--
-- Inputs -
--	nEventIdDay int.
--  nEventIdFraction int.
--  @dtEventTime datetime,
--  @nType int,
--  @nCategory int,
--  @nBlockKey int
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- Joe Fisher 9/20/2004
--
CREATE PROCEDURE AmsSp_NotifyQ_PushEventLogInsert_1
@nEventIdDay int,
@nEventIdFraction int,
@dtEventTime datetime,
@nType int,
@nCategory int,
@nBlockKey int
AS

set nocount on

declare @nReturn int
set @nReturn = 0

declare @nNotifyType int
declare @sNotifyData nvarchar(max)
exec @nReturn = AmsSp_NotifyData_BuildEventLogInsert_1 @nEventIdDay,
														@nEventIdFraction,
														@dtEventTime,
														@nType,
														@nCategory,
														@nBlockKey,
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

