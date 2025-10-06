----------------------------------------------------------------------
-- AmsSp_NotifyData_BuildRenameDevice_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
--  @nBlockKey int
--	@nPlantServerKey int
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
-- Joe Fisher 10/27/2004
--
CREATE PROCEDURE AmsSp_NotifyData_BuildRenameDevice_1
@nBlockKey int,
@nPlantServerKey int,
@nNotifyType int output,
@sNotifyData nvarchar(max) output
AS
declare @nReturn int
set @nReturn = 0

set @nNotifyType = 5
set @sNotifyData = ''
set @sNotifyData = @sNotifyData + '<NotifyData>'
set @sNotifyData = @sNotifyData + '<PlantServerKey>' + cast(@nPlantServerKey as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '<BlockKey>' + cast(@nBlockKey as nvarchar(10)) + '</>'
set @sNotifyData = @sNotifyData + '</NotifyData>'

return @nReturn

GO

