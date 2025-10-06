
----------------------------------------------------------------------
-- AmsSp_AL_ProcessNotifyEventLogInsert_1
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
CREATE PROCEDURE AmsSp_AL_ProcessNotifyEventLogInsert_1
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

-- breakout the event info from the notifyData.
declare @nEventIdDay int
declare @nEventIdFraction int
declare @dtEventTime datetime
declare @nType int
declare @nCategory int
declare @nBlockKey int

exec @nReturn = AmsSp_NotifyData_CrackEventLogInsert_1 @sNotifyData,
							@nEventIdDay output,
							@nEventIdFraction output,
							@dtEventTime output,
							@nType output,
							@nCategory output,
							@nBlockKey output

if (@nReturn <> 0)
begin
	return @nReturn
end
/*
print 'AmsSp_AL_ProcessNotifyEventLogInsert_1 ...'
print 'EventIdDay=' + cast(@nEventIdDay as nvarchar(10))
print 'EventIdFraction=' + cast(@nEventIdFraction as nvarchar(10))
print 'EventTime=' + convert(nvarchar(30), @dtEventTime, 126)
print 'Type=' + cast(@nType as nvarchar(10))
print 'Category=' + cast(@nCategory as nvarchar(10))
print 'BlockKey=' + cast(@nBlockKey as nvarchar(10))
*/

if (@nCategory in (54,55))
begin
	--print 'Alert Monitor change'
	set @nPSAMUpdated = 1
end

return @nReturn

GO

