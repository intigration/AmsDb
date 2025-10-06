
----------------------------------------------------------------------
-- AmsSp_NotifyData_CrackDeviceMonitorListItemUpdate_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
--  @sNotifyData  nvarchar(max) - the notifyData packet.
--
-- Outputs -
--  @nBlockKey int
--	@dtStartTime datetime - where to start in the EventLog building the AL.
--
-- Returns -
--	0 - successful.
--	-1 - not found.
--  -2 - error.
--
-- Joe Fisher 10/05/2004
--
CREATE PROCEDURE AmsSp_NotifyData_CrackDeviceMonitorListItemUpdate_1
@sNotifyData nvarchar(max),
@nBlockKey int output,
@dtStartTime datetime output
AS
declare @nReturn int
set @nReturn = 0
set @nBlockKey = -1

declare @sVal nvarchar(1024)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'BlockKey', @sVal output
if (@nReturn <> 0) return @nReturn
set @nBlockKey = cast(@sVal as int)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'StartTime', @sVal output
if (@nReturn <> 0) return @nReturn
set @dtStartTime = cast(@sVal as datetime)

return @nReturn

GO

