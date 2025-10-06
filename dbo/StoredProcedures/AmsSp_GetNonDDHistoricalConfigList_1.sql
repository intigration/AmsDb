
----------------------------------------------------------------------
-- AmsSp_GetNonDDHistoricalConfigList_1
--
-- Get Non-DD parameters for the device currently assigned to the given AmsTag.
--
-- Inputs -
--	@sAmsTag nvarchar(255)	This is the tag name.
--
-- Output -
--	A recordset containing a list of Non_DD parameter events
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- Nghy Hong 10/27/2004
-- Nghy Hong 6/17/2009	convert ParamData to varbinary if the ParamDataType = 12 (TString)
--
CREATE PROCEDURE AmsSp_GetNonDDHistoricalConfigList_1
@sAmsTag nvarchar(255)
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY;
	WITH TmpTable1
	AS
	(
		SELECT  BlockData.EventIdDay, BlockData.EventIdFraction, EventLog.EventTime,
		BlockData.ParamKind, BlockData.ParamName, BlockData.ParamDataType,
		BlockData.ParamDataSize, BlockData.ParamData
		FROM    Blocks INNER JOIN
			BlockData ON Blocks.BlockKey = BlockData.BlockKey
		INNER JOIN EventLog ON EventLog.EventIdDay = BlockData.EventIdDay
		AND EventLog.EventIdFraction = BlockData.EventIdFraction
		WHERE   BlockData.ParamKind = 'D' AND
		Blocks.DeviceKey = (
			SELECT Blocks.DeviceKey
			FROM   ExtBlockTags INNER JOIN
				   BlockAsgms ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey 
				   AND BlockAsgms.EventIdDayOut = 49710 
				   INNER JOIN Blocks ON BlockAsgms.BlockKey = Blocks.BlockKey
			WHERE  ExtBlockTags.ExtBlockTag = @sAmsTag )
	),
	TmpTable2
	AS
	(
		SELECT EventIdDay, EventIdFraction, EventTime, ParamKind,
		ParamName, ParamDataType, ParamDataSize, 
		convert(nvarchar(max), convert(varbinary(max), ParamData)) AS ParamData
		FROM TmpTable1
		WHERE ParamDataType = 12
		UNION
		SELECT EventIdDay, EventIdFraction, EventTime, ParamKind,
		ParamName, ParamDataType, ParamDataSize, ParamData
		FROM TmpTable1
		WHERE ParamDataType <> 12
	)
	SELECT * FROM TmpTable2
	ORDER BY EventIdDay DESC, EventIdFraction DESC;

END TRY
BEGIN CATCH
	set @nReturn = -1;
END CATCH

RETURN @nReturn;

GO

