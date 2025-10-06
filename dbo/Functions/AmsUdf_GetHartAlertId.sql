
-------------------------------------------------------------------------------
-- AmsUdf_GetHartAlertId 
--
--	Get alert identifier for the given StatusEnableBits.
--
-- Inputs --
--  @nStatusEnableBit - Alert StatusEnableBits
--
-- Outputs --
--	Standard HART alert identifiers if StatusEnableBits is a valid alert status bit, 
--	otherwise the word 'Invalid_StatusEnableBit' is returned
--
-- Note --
--	This function is defined in two places (Createviews.sql and v1_7_to_v1_8.sql)
--
-- Author --
--	Nghy Hong 01/10/2008
--
--
CREATE FUNCTION AmsUdf_GetHartAlertId
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

	declare @sAlertId nvarchar(256);
	
	select @sAlertId =
		case @nStatusEnableBit 
			--when @DBW_DVS_DEVICE_STATUS_NONE			then  '0000000000000000'
			when @DBW_DVS_PV_OUT_OF_LIMITS				then  N'0100000000000000'
			when @DBW_DVS_NON_PV_OUT_OF_LIMITS			then  N'0200000000000000'
			when @DBW_DVS_PV_ANALOG_OUTPUT_SATURATED	then  N'0400000000000000'
			when @DBW_DVS_PV_ANALOG_OUTPUT_FIXED		then  N'0800000000000000'
			when @DBW_DVS_MORE_STATUS_AVAILABLE			then  N'1000000000000000'
			when @DBW_DVS_COLD_STATUS					then  N'2000000000000000'
			when @DBW_DVS_CONFIGURATION_CHANGED			then  N'4000000000000000'
			when @DBW_DVS_DEVICE_MALFUNCTION			then  N'8000000000000000'
			when @DBW_DVS_NO_RESPONSE					then  N'0001000000000000'
			else N'Invalid_StatusEnableBit'
		end;

	return @sAlertId;
END;

GO

