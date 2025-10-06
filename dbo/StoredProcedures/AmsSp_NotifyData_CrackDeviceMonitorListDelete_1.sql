
----------------------------------------------------------------------
-- AmsSp_NotifyData_CrackDeviceMonitorListDelete_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
--  @sNotifyData  nvarchar(max) - the notifyData packet.
--
-- Outputs -
--  @nBlockKey int
--
-- Returns -
--	0 - successful.
--	-1 - not found.
--  -2 - error.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_NotifyData_CrackDeviceMonitorListDelete_1
@sNotifyData nvarchar(max),
@nBlockKey int output
AS
declare @nReturn int
set @nReturn = 0
set @nBlockKey = -1

declare @sVal nvarchar(1024)

exec @nReturn = AmsSp_NotifyData_GetElementValue_1 @sNotifyData, 'BlockKey', @sVal output
if (@nReturn <> 0) return @nReturn
set @nBlockKey = cast(@sVal as int)

return @nReturn

GO

