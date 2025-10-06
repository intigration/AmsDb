
-----------------------------------------------------------------------
-- AmsSp_GetDDHelpTextByTag_1
--
--	retrieves the DD help text from the ExtDeviceAlertDesc table
--
-- Inputs --
--		@sAmsTag - device tag
--		@sAlertId - alert
--
-- Outputs --
--		@sDDHelp - help text
--
-- Recordset output --
--
-- Returns -
--	0 - successful.
--	-1 - Error
--
-- James Kramer 2/5/2008
--
CREATE PROCEDURE AmsSp_GetDDHelpTextByTag_1
@sAmsTag nvarchar(256),
@sAlertId nvarchar(1024),
@sDDHelp nvarchar(4000) output
AS

set nocount on
declare @nReturn int
set @nReturn = 0

declare @nMfrId int
declare @sProtocol nvarchar(256)
declare @nDeviceTypeCode int
declare @nDeviceRevisionCode int

set @sDDHelp = ''
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

exec @nReturn = AmsSp_GetDDHelpTextByType_1 @nMfrId, @sProtocol, @nDeviceTypeCode, @nDeviceRevisionCode, @sAlertId, @sDDHelp output

return @nReturn

GO

