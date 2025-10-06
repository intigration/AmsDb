
----------------------------------------------------------------------
-- AmsSp_GetCurrentNonDDParam_1
--
-- Get current specified Non-DD parameter for the given Ams Tag
--
-- Inputs -
--	@sAmsTag nvarchar(255)	This is the tag name.
--	@sParamName nvarchar(255) NonDD parameter name
--
-- Output -
--	@sParamData varchar(max) NonDD Parameter value
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--  -2 - AmsTag not found in database
--  -3 - Parameter name not found in database
--  -4 - Invalid data type (expect generic string or narrow string)
--
-- Nghy Hong 1/24/2012
--
CREATE PROCEDURE AmsSp_GetCurrentNonDDParam_1
@sAmsTag nvarchar(255),
@sParamName nvarchar(255),
@sParamData varchar(max) output
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY
	declare @sData varchar(max);
	declare @iParamType int;
	declare @sName varchar(max);
	set @sName = null;
	
	if exists (select AmsTag from AmsVw_BlockTags where AmsVw_BlockTags.AmsTag = @sAmsTag)
	begin
		SELECT top 1 @sName = BlockData.ParamName, @sData = BlockData.ParamData, @iParamType = BlockData.ParamDataType
		FROM  AmsVw_BlockTags INNER JOIN
		BlockData ON AmsVw_BlockTags.BlockKey = BlockData.BlockKey
		WHERE (AmsVw_BlockTags.AmsTag = @sAmsTag) AND (BlockData.ParamName = @sParamName)
		ORDER BY BlockData.EventIdDay DESC, BlockData.EventIdFraction DESC;
		
		if ( @sName is not null)
		begin
			if @iParamType = 12
				set @sParamData = convert(nvarchar(max), convert(varbinary, @sData));--Generic string. parameter type = 12
			else if @iParamType = 3
				set @sParamData = @sData;  --Narrow string, parameter type = 3
			else
				set @nReturn = -4;
		end
		else
			set @nReturn = -3;
	end
	else
		set @nReturn = -2;

END TRY
BEGIN CATCH
	set @nReturn = -1;
END CATCH

RETURN @nReturn;

GO

