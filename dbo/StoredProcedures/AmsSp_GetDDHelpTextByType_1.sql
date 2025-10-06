
-----------------------------------------------------------------------
-- AmsSp_GetDDHelpTextByType_1
--
--	retrieves the DD help text from the ExtDeviceAlertDesc table
--
-- Inputs --
--		@nMfr - manufacturer
--		@sProtocol - protocol
--		@nDeviceType - device type
--		@nDeviceRevision - device revision
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
CREATE PROCEDURE AmsSp_GetDDHelpTextByType_1
@nMfr int,
@sProtocol nvarchar(256),
@nDeviceType int,
@nDeviceRevision int,
@sAlertId nvarchar(1024),
@sDDHelp nvarchar(4000) output
AS

set nocount on
declare @nReturn int
set @nReturn = 0

declare @nBlockKey int
declare @nAmsDevRevId int
declare @nAlertDescId int

set @sDDHelp = ''
set @nAmsDevRevId = -1
set @nAlertDescId = -1

select  @nAlertDescId = AlertDescId
from DeviceAlertDesc INNER JOIN
	 AmsVw_DeviceTypes ON DeviceAlertDesc.AmsDevRevId = AmsVw_DeviceTypes.AmsDevRevId
where DeviceTypeCode = cast(@nDeviceType as nvarchar(255)) and MfrId = cast(@nMfr as nvarchar(255)) and DeviceRevisionCode = cast(@nDeviceRevision as nvarchar(255)) and Protocol = @sProtocol and AlertId = @sAlertId

if (@nAlertDescId = -1)
begin
	return -1
end

select @sDDHelp = DDHelpText
from ExtDeviceAlertDesc
where AlertDescId = @nAlertDescId 

return @nReturn

GO

