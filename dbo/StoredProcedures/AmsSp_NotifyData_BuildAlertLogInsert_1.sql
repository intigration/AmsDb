----------------------------------------------------------------------
-- AmsSp_NotifyData_BuildAlertLogInsert_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
--	nEventIdDay int.
--  nEventIdFraction int.
--  @sAlertId nvarchar(1024)
--  @nAlertTypeId smallint
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
CREATE PROCEDURE AmsSp_NotifyData_BuildAlertLogInsert_1
@nEventIdDay int,
@nEventIdFraction int,
@sAlertId nvarchar(1024),
@nAlertTypeId smallint,
@nNotifyType int output,
@sNotifyData nvarchar(max) output
AS
declare @nReturn int
set @nReturn = 0

set @nNotifyType = 2
set @sNotifyData = ''
set @sNotifyData = @sNotifyData + '<NotifyData>'
set @sNotifyData = @sNotifyData + '<EventIdDay>' + cast(@nEventIdDay as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '<EventIdFraction>' + cast(@nEventIdFraction as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '<AlertId>' + @sAlertId + '</>'
set @sNotifyData = @sNotifyData + '<AlertTypeId>' + cast(@nAlertTypeId as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '</NotifyData>'

return @nReturn

GO

