-----------------------------------------------------------------------
-- AmsSp_GetBlockKeyCurrentHartInfo_1
--
-- Get device-block block key current HART tag or HART descriptor, or HART message.
--
-- Inputs -
--	block key	integer		the device-block's database blockKey.
--	request string	nvarchar(255)	be one of the followings
--						"tag.0000A3.0000.0000", to get the HART tag
--						"message.000000A4.0000.0000", to get the HART message
--						"descriptor.000000A5.0000.0000", to get the HART descriptor
--
-- Outputs -
--	HART tag or HART descriptor or HART message	nvarchar(255)
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information or record not found.
--  -2 - Error, invalid data type
--
-- Luong Chau 5/8/2003
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetBlockKeyCurrentHartInfo_1
@nBlockKey as integer,
@sRequestString as nvarchar(255),
@sHartInfo as nvarchar(255) OUTPUT
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0
declare @ParamData varbinary(max)
declare @iParamType int

SELECT top 1 @ParamData = convert(varbinary(255), dbo.BlockData.ParamData), @iParamType = dbo.BlockData.ParamDataType
FROM dbo.BlockData INNER JOIN dbo.EventLog ON 
    dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND 
    dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
WHERE (dbo.BlockData.ParamName = @sRequestString) 
    AND (dbo.BlockData.BlockKey = @nBlockKey)
order by dbo.EventLog.EventIdDay DESC, dbo.EventLog.EventIdFraction DESC

if (@@ERROR <> 0)
	set @iReturnVal = -1
else
begin
	if @iParamType = 3			--Narrow string, parameter type = 3
		set @sHartInfo = convert(varchar(max), @ParamData)
	else if @iParamType = 12			--Generic string. parameter type = 12
		set @sHartInfo = convert(nvarchar(max), @ParamData)
	else
		set @iReturnVal = -2
end

return @iReturnVal

GO

