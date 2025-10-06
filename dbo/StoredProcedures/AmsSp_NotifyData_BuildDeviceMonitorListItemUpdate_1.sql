
----------------------------------------------------------------------
-- AmsSp_NotifyData_BuildDeviceMonitorListItemUpdate_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
--  @nBlockKey int
--	@dtStartTime datetime - where to start in the EventLog building the AL.
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
CREATE PROCEDURE AmsSp_NotifyData_BuildDeviceMonitorListItemUpdate_1
@nBlockKey int,
@dtStartTime datetime,
@nNotifyType int output,
@sNotifyData nvarchar(max) output
AS
declare @nReturn int
set @nReturn = 0

set @nNotifyType = 4
set @sNotifyData = ''
set @sNotifyData = @sNotifyData + '<NotifyData>'
set @sNotifyData = @sNotifyData + '<BlockKey>' + cast(@nBlockKey as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '<StartTime>' + cast(@dtStartTime as nvarchar(20)) + '</>'
set @sNotifyData = @sNotifyData + '</NotifyData>'

return @nReturn

GO

