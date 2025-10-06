
-------------------------------------------------------------------------------
-- AmsUdf_AlertTypeUidFromParamName 
--
-- Get the alertTypeUid from the paramName.
--
-- Inputs --
--	@sParamName nvarchar(4096) - the paramname of the form- 'frsi.DeviceAlert.<AlertTypeUid>'.
--
-- Outputs --
--	sAlertTypeUid as nvarchar(255)
--
-- Author --
--	Joe Fisher
--	11/03/04
--
CREATE  FUNCTION AmsUdf_AlertTypeUidFromParamName 
(@sParamName nvarchar(max))  
RETURNS nvarchar(255)
AS  
begin 
	declare @sStartString nvarchar(30)
	set @sStartString = N'frsi.DeviceAlarm.'
	declare @nStartPos int
	set @nStartPos = len(@sStartString)
	-- make sure paramName has the start string.
	if (left(@sParamName, @nStartPos) = @sStartString)
	begin
		-- we have a valid alertTypeUid paramname
		declare @nLen int
		set @nLen = len(@sParamName) - (@nStartPos)
		if (@nLen > 0)
		begin
			return (substring(@sParamName, @nStartPos+1, @nLen))
		end
	end

	-- if we get here just return blank.
	return N''
end

GO

