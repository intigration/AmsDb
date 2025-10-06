
----------------------------------------------------------------------
-- AmsSp_NotifyData_BuildDeviceMonitorListDelete_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
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
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_NotifyData_BuildDeviceMonitorListDelete_1
@nBlockKey int,
@nNotifyType int output,
@sNotifyData nvarchar(max) output
AS
declare @nReturn int
set @nReturn = 0

set @nNotifyType = 3
set @sNotifyData = ''
set @sNotifyData = @sNotifyData + '<NotifyData>'
set @sNotifyData = @sNotifyData + '<BlockKey>' + cast(@nBlockKey as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '</NotifyData>'

return @nReturn

GO

