----------------------------------------------------------------------
-- AmsSp_NotifyData_CrackAlertLogInsert_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
--  @sNotifyData  nvarchar(max) - the notifyData packet.
--
-- Outputs -
--	nEventIdDay int.
--  nEventIdFraction int.
--  @sAlertId nvarchar(1024)
--  @nAlertTypeId smallint
--
-- Returns -
--	0 - successful.
--	-1 - not found.
--  -2 - error.
--
-- Joe Fisher 9/22/2004
--
CREATE PROCEDURE AmsSp_NotifyData_CrackAlertLogInsert_1
@sNotifyData nvarchar(max),
@nEventIdDay int output,
@nEventIdFraction int output,
@sAlertId nvarchar(1024) output,
@nAlertTypeId smallint output
AS
declare @nReturn int
set @nReturn = 0

set @nEventIdDay = 0
set @nEventIdFraction = 0
set @sAlertId = ''
set @nAlertTypeId = 0

declare @sVal nvarchar(1024)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'EventIdDay', @sVal output
if (@nReturn <> 0) return @nReturn
set @nEventIdDay = cast(@sVal as int)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'EventIdFraction', @sVal output
if (@nReturn <> 0) return @nReturn
set @nEventIdFraction = cast(@sVal as int)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'AlertId', @sAlertId output
if (@nReturn <> 0) return @nReturn

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'AlertTypeId', @sVal output
if (@nReturn <> 0) return @nReturn
set @nAlertTypeId = cast(@sVal as smallint)

return @nReturn

GO

