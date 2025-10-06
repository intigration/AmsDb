
-----------------------------------------------------------------------
-- AmsSp_GetExtendedHelpTextByTag_1
--
--	retrieves the extended help text from the ExtDeviceAlertDesc table
--
-- Inputs --
--		@sAmsTag - device tag
--		@sAlertId - alert
--
-- Outputs --
--		@sExtHelp - help text
--
-- Recordset output --
--
-- Returns -
--	0 - successful.
--	-1 - Error
--
-- James Kramer 2/5/2008
--
CREATE PROCEDURE AmsSp_GetExtendedHelpTextByTag_1
@sAmsTag nvarchar(256),
@sAlertId nvarchar(1024),
@sExtHelp nvarchar(4000) output
AS

set nocount on
declare @nReturn int
set @nReturn = 0

declare @nMfrId int
declare @sProtocol nvarchar(256)
declare @nDeviceTypeCode int
declare @nDeviceRevisionCode int

set @sExtHelp = ''
set @nMfrId = -1
set @sProtocol = ''
set @nDeviceTypeCode = -1
set @nDeviceRevisionCode = -1

select @nMfrId = MfrId,
	   @sProtocol = Protocol,
	   @nDeviceTypeCode = DeviceTypeCode,
	   @nDeviceRevisionCode = DeviceRevisionCode
from AmsVw_BlockTags
where AmsTag = @sAmsTag

if (@nMfrId = -1)
begin
	return -1
end

exec @nReturn = AmsSp_GetExtendedHelpTextByType_1 @nMfrId, @sProtocol, @nDeviceTypeCode, @nDeviceRevisionCode, @sAlertId, @sExtHelp output

return @nReturn

GO

