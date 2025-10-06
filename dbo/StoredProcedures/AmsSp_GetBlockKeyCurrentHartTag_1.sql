
-----------------------------------------------------------------------
-- AmsSp_GetBlockKeyCurrentHartTag_1
--
-- Get device-block block key current HART tag.
--
-- Inputs -
--	block key	integer		the device-block's database blockKey.
--
-- Outputs -
--	HART tag	nvarchar(255)
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information or record not found.
--
-- Joe Fisher, 11/14/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetBlockKeyCurrentHartTag_1
@nBlockKey as integer,
@sHartTag as nvarchar(255) OUTPUT
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0
declare @ParamData varbinary(max)
declare @iParamType int

SELECT top 1 @ParamData = convert(varbinary, dbo.BlockData.ParamData), @iParamType = dbo.BlockData.ParamDataType
FROM dbo.BlockData INNER JOIN dbo.EventLog ON 
    dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND 
    dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
WHERE (dbo.BlockData.ParamName = 'tag.000000A3.0000.0000') 
    AND (dbo.BlockData.BlockKey = @nBlockKey)
order by dbo.EventLog.EventIdDay DESC, dbo.EventLog.EventIdFraction DESC

if (@@ERROR <> 0)
	set @iReturnVal = -1
else
begin
	if @iParamType = 3			--Narrow string, parameter type = 3
		set @sHartTag = convert(varchar(max), @ParamData)
	else						--Generic string. parameter type = 12
		set @sHartTag = convert(nvarchar(max), @ParamData)
end

return @iReturnVal

GO

