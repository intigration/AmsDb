-----------------------------------------------------------------------
-- AmsSp_UpdateDefaultAlerts_1
--
-- Adds the default HART alerts if they do not exist.
--
-- Inputs -
-- @nMfrId int
-- @sProtocol nvarchar(255)
-- @nDevType int
-- @nDevRev int
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--  -2 - exception
--
-- James Kramer - 11/03/2008
--

CREATE PROCEDURE AmsSp_UpdateDefaultAlerts_1
@nMfrId int,
@sProtocol nvarchar(255),
@nDevType int,
@nDevRev int
AS
declare @count int
declare @error int
declare @iReturnVal int
set @iReturnVal = 0

declare @sAlertDesc1 nvarchar(256)
declare @sAlertDesc2 nvarchar(256)
declare @sAlertDesc3 nvarchar(256)
declare @sAlertDesc4 nvarchar(256)
declare @sAlertDesc5 nvarchar(256)
declare @sAlertDesc6 nvarchar(256)
declare @sAlertDesc7 nvarchar(256)
declare @sAlertDesc8 nvarchar(256)
declare @sAlertDesc9 nvarchar(256)

declare @sAlert1 nvarchar(256)
declare @sAlert2 nvarchar(256)
declare @sAlert3 nvarchar(256)
declare @sAlert4 nvarchar(256)
declare @sAlert5 nvarchar(256)
declare @sAlert6 nvarchar(256)
declare @sAlert7 nvarchar(256)
declare @sAlert8 nvarchar(256)
declare @sAlert9 nvarchar(256)

BEGIN TRY

if (@sProtocol = 'HART')
begin
	set @sAlert1 = dbo.AmsUdf_GetHartAlertId(1)
	set @sAlert2 = dbo.AmsUdf_GetHartAlertId(2)
	set @sAlert3 = dbo.AmsUdf_GetHartAlertId(4)
	set @sAlert4 = dbo.AmsUdf_GetHartAlertId(8)
	set @sAlert5 = dbo.AmsUdf_GetHartAlertId(16)
	set @sAlert6 = dbo.AmsUdf_GetHartAlertId(32)
	set @sAlert7 = dbo.AmsUdf_GetHartAlertId(64)
	set @sAlert8 = dbo.AmsUdf_GetHartAlertId(128)
	set @sAlert9 = dbo.AmsUdf_GetHartAlertId(256)

	exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert1, @sAlertDesc1 output

	if (@iReturnVal = 0)
	begin
		exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert2, @sAlertDesc2 output
	end

	if (@iReturnVal = 0)
	begin
		exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert3, @sAlertDesc3 output
	end

	if (@iReturnVal = 0)
	begin
		exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert4, @sAlertDesc4 output
	end

	if (@iReturnVal = 0)
	begin
		exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert5, @sAlertDesc5 output
	end

	if (@iReturnVal = 0)
	begin
		exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert6, @sAlertDesc6 output
	end

	if (@iReturnVal = 0)
	begin
		exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert7, @sAlertDesc7 output
	end

	if (@iReturnVal = 0)
	begin
		exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert8, @sAlertDesc8 output
	end

	if (@iReturnVal = 0)
	begin
		exec @iReturnVal = dbo.AmsSp_GetDefaultHartAlertDesc_1 @sAlert9, @sAlertDesc9 output
	end

	if (@iReturnVal = 0)
	begin
		select @count = count(*)
		from DeviceAlertDesc INNER JOIN
			 AmsVw_DeviceTypes ON DeviceAlertDesc.AmsDevRevId = AmsVw_DeviceTypes.AmsDevRevId
		where (DeviceTypeCode = cast(@nDevType as nvarchar(255)) and MfrId = cast(@nMfrId as nvarchar(255)) and DeviceRevisionCode = cast(@nDevRev as nvarchar(255)) and Protocol = @sProtocol and
			   ((AlertId = @sAlert1) or (AlertId = @sAlert2) or (AlertId = @sAlert3) or (AlertId = @sAlert4) or (AlertId = @sAlert5) or
				(AlertId = @sAlert6) or (AlertId = @sAlert7) or (AlertId = @sAlert8) or (AlertId = @sAlert9)))

		if (@count <> 9)
		begin
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert1,'ALERT_ABNORM_ID',@sAlertDesc1,'',''
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert2,'ALERT_ABNORM_ID',@sAlertDesc2,'',''
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert3,'ALERT_ABNORM_ID',@sAlertDesc3,'',''
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert4,'ALERT_ABNORM_ID',@sAlertDesc4,'',''
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert5,'ALERT_ABNORM_ID',@sAlertDesc5,'',''
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert6,'ALERT_ABNORM_ID',@sAlertDesc6,'',''
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert7,'ALERT_ABNORM_ID',@sAlertDesc7,'',''
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert8,'ALERT_ABNORM_ID',@sAlertDesc8,'',''
			exec AmsSp_AddDeviceAlertDesc_1 @nMfrId, @nDevType, @nDevRev, @sProtocol, @sAlert9,'ALERT_ABNORM_ID',@sAlertDesc9,'',''
		end
	end
end
END TRY
BEGIN CATCH
	set @iReturnVal = -2
END CATCH

return @iReturnVal

GO

