----------------------------------------------------------------------
-- AmsSp_NotifyData_CrackEventLogInsert_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
--  @sNotifyData  nvarchar(max) - the notifyData packet.
--
-- Outputs -
--	nEventIdDay int.
--  nEventIdFraction int.
--  @dtEventTime datetime,
--  @nType int,
--  @nCategory int,
--  @nBlockKey int
--
-- Returns -
--	0 - successful.
--	-1 - not found.
--  -2 - error.
--
-- Joe Fisher 9/22/2004
--
CREATE PROCEDURE AmsSp_NotifyData_CrackEventLogInsert_1
@sNotifyData nvarchar(max),
@nEventIdDay int output,
@nEventIdFraction int output,
@dtEventTime datetime output,
@nType int output,
@nCategory int output,
@nBlockKey int output
AS
declare @nReturn int
set @nReturn = 0

set @nEventIdDay = 0
set @nEventIdFraction = 0
set @dtEventTime = '1970-01-01T12:00:00'
set @nType = 0
set @nCategory = 0
set @nBlockKey = -1

declare @sVal nvarchar(1024)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'EventIdDay', @sVal output
if (@nReturn <> 0) return @nReturn
set @nEventIdDay = cast(@sVal as int)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'EventIdFraction', @sVal output
if (@nReturn <> 0) return @nReturn
set @nEventIdFraction = cast(@sVal as int)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'EventTime', @sVal output
if (@nReturn <> 0) return @nReturn
set @dtEventTime = cast(@sVal as datetime)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'Type', @sVal output
if (@nReturn <> 0) return @nReturn
set @nType = cast(@sVal as int)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'Category', @sVal output
if (@nReturn <> 0) return @nReturn
set @nCategory = cast(@sVal as int)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'BlockKey', @sVal output
if (@nReturn <> 0) return @nReturn
set @nBlockKey = cast(@sVal as int)

return @nReturn

GO

