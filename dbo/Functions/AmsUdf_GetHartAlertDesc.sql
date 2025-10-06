
-------------------------------------------------------------------------------
-- AmsUdf_GetHartAlertDesc 
--
--	Get alert identifier description for the given StatusEnableBits.
--
-- Inputs --
--  @nStatusEnableBit - Alert StatusEnableBits
--
-- Outputs --
--	Standard HART alert identifiers description if StatusEnableBits is a valid alert status bit, 
--	otherwise the word 'Invalid_StatusEnableBit' is returned
--
-- Note --
--	This function is defined in two places (Createviews.sql and v1_7_to_v1_8.sql)
--
-- Author --
--	Nghy Hong 01/10/2008
--
--
CREATE FUNCTION AmsUdf_GetHartAlertDesc
(@nStatusEnableBit int)
RETURNS NVARCHAR(256)
AS
BEGIN
	-- Standard HART alert identifiers 
	declare @DBW_DVS_DEVICE_STATUS_NONE int;
	declare @DBW_DVS_PV_OUT_OF_LIMITS int;
	declare @DBW_DVS_NON_PV_OUT_OF_LIMITS int;
	declare @DBW_DVS_PV_ANALOG_OUTPUT_SATURATED int;
	declare @DBW_DVS_PV_ANALOG_OUTPUT_FIXED int;
	declare @DBW_DVS_MORE_STATUS_AVAILABLE int;
	declare @DBW_DVS_COLD_STATUS int;
	declare @DBW_DVS_CONFIGURATION_CHANGED int;
	declare @DBW_DVS_DEVICE_MALFUNCTION int;
	declare @DBW_DVS_NO_RESPONSE int;
	set @DBW_DVS_DEVICE_STATUS_NONE			=	0x00000000;
	set @DBW_DVS_PV_OUT_OF_LIMITS			=	0x00000001;
	set @DBW_DVS_NON_PV_OUT_OF_LIMITS		=	0x00000002;
	set @DBW_DVS_PV_ANALOG_OUTPUT_SATURATED	=	0x00000004;
	set @DBW_DVS_PV_ANALOG_OUTPUT_FIXED		=	0x00000008;
	set @DBW_DVS_MORE_STATUS_AVAILABLE		=	0x00000010;
	set @DBW_DVS_COLD_STATUS				=	0x00000020;
	set @DBW_DVS_CONFIGURATION_CHANGED		=	0x00000040;
	set @DBW_DVS_DEVICE_MALFUNCTION			=	0x00000080;
	set @DBW_DVS_NO_RESPONSE				=	0x00000100;

	declare @sAlertDesc nvarchar(256);
	
	select @sAlertDesc =
		case @nStatusEnableBit 
			--when @DBW_DVS_DEVICE_STATUS_NONE			then  '00000000'
			when @DBW_DVS_PV_OUT_OF_LIMITS				then  N'Primary variable out of limits'
			when @DBW_DVS_NON_PV_OUT_OF_LIMITS			then  N'Non-primary variable out of limits'
			when @DBW_DVS_PV_ANALOG_OUTPUT_SATURATED	then  N'Primary variable analog output saturated'
			when @DBW_DVS_PV_ANALOG_OUTPUT_FIXED		then  N'Primary variable analog output fixed'
			when @DBW_DVS_MORE_STATUS_AVAILABLE			then  N'More status available'
			when @DBW_DVS_COLD_STATUS					then  N'Cold start'
			when @DBW_DVS_CONFIGURATION_CHANGED			then  N'Configuration changed'
			when @DBW_DVS_DEVICE_MALFUNCTION			then  N'Field device malfunction'
			when @DBW_DVS_NO_RESPONSE					then  N'Device Not Responding'
			else N'Invalid_StatusEnableBit'
		end;

	return @sAlertDesc;
END;

GO

