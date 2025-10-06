----------------------------------------------------------------------
-- AmsSp_NotifyQ_PushAlertLogInsert_1
--
-- Add a alertLog insert notification to the notifyQ table.
--
-- Inputs -
--	nEventIdDay int.
--  nEventIdFraction int.
--  @sAlertId nvarchar(1024)
--  @nAlertTypeId smallint
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- Joe Fisher 9/22/2004
--
CREATE PROCEDURE AmsSp_NotifyQ_PushAlertLogInsert_1
@nEventIdDay int,
@nEventIdFraction int,
@sAlertId nvarchar(1024),
@nAlertTypeId smallint
AS

set nocount on

declare @nReturn int
set @nReturn = 0

declare @nNotifyType int
declare @sNotifyData nvarchar(max)
exec @nReturn = AmsSp_NotifyData_BuildAlertLogInsert_1 @nEventIdDay,
														@nEventIdFraction,
														@sAlertId,
														@nAlertTypeId,
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

