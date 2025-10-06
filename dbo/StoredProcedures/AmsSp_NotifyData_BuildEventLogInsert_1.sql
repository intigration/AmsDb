----------------------------------------------------------------------
-- AmsSp_NotifyData_BuildEventLogInsert_1
--
-- Get the element value from the notifyData.
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
--  @nNotifyType  int
--  @sNotifyData  nvarchar(max) - the notifyData packet.
--
-- Returns -
--	0 - successful.
--	-1 - not found.
--  -2 - error.
--
-- Joe Fisher 9/22/2004
--
CREATE PROCEDURE AmsSp_NotifyData_BuildEventLogInsert_1
@nEventIdDay int,
@nEventIdFraction int,
@dtEventTime datetime,
@nType int,
@nCategory int,
@nBlockKey int,
@nNotifyType int output,
@sNotifyData nvarchar(max) output
AS
declare @nReturn int
set @nReturn = 0

set @nNotifyType = 1
set @sNotifyData = ''
set @sNotifyData = @sNotifyData + '<NotifyData>'
set @sNotifyData = @sNotifyData + '<EventIdDay>' + cast(@nEventIdDay as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '<EventIdFraction>' + cast(@nEventIdFraction as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '<EventTime>' + convert(nvarchar(30), @dtEventTime, 126) + '</>'
set @sNotifyData = @sNotifyData + '<Type>' + cast(@nType as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '<Category>' + cast(@nCategory as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '<BlockKey>' + cast(@nBlockKey as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '</NotifyData>'

return @nReturn

GO

