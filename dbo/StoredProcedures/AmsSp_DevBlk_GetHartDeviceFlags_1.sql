-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetHartDeviceFlags_1
--
-- Get the latest HART device_flag parameter value for the devBlkKey.
--
--
-- Inputs -
--	@nDeviceLevelBlockKey	int
--
-- Outputs -
--	@sValue			nvarchar(10)
--		Will be blank if not found.
--	
--
-- Returns -
--	0 - successful.
--
-- Joe Fisher / Nghy Hong - 08/09/2006
--

CREATE PROCEDURE AmsSp_DevBlk_GetHartDeviceFlags_1
@nDeviceLevelBlockKey	int,
@sValue	nvarchar(10) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sValue = ''

declare @paramData varchar(max)
set @paramData = null

-- note: this works only for HART device types.
SELECT TOP 1 @paramData = blockData.paramData
	FROM BlockData INNER JOIN EventLog ON BlockData.EventIdDay = EventLog.EventIdDay AND BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
	WHERE (BlockData.BlockKey = @nDeviceLevelBlockKey) AND (BlockData.ParamName LIKE 'device_flags%')
	ORDER BY EventLog.EventTime DESC

if (@paramData is null)
begin
--	print '@paramData not found for devBlockKey- ' + cast(@nDeviceLevelBlockKey as nvarchar(10))
	set @sValue = ''
end
else
begin
	declare @nValue int
	-- we need to reconstruct the parameter data.
	set @nValue = cast(cast(left(@paramData,1) as binary(1)) as int)
	set @nValue = @nValue + (cast(cast(substring(@paramData,2,1) as binary(1)) as int) * 256)
	set @nValue = @nValue + (cast(cast(substring(@paramData,3,1) as binary(1)) as int) * 65536)
	set @nValue = @nValue + (cast(cast(substring(@paramData,4,1) as binary(1)) as int) * 16777216)
	set @sValue = cast(@nValue as nvarchar(20))
--	print 'HART device_flag = ' + @sValue
end

return @iReturnVal

GO

