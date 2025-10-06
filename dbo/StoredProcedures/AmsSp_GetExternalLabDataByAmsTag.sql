----------------------------------------------------------------------------
-- AmsSp_GetExternalLabDataByAmsTag
--
--	Gets External Lab Data of a certain AmsTag
-- 
-- Returns -
--	-1 - General error.
--
-- Enrico Resurreccion - 03/20/2012
CREATE PROCEDURE AmsSp_GetExternalLabDataByAmsTag
@AmsTag nvarchar(255)
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY;
	WITH TempTable1 AS
	(
		--Get the latest calibration data event related to the given device's tag.
		--Note: Just only want one event date/time without other heavy baggages.
		SELECT TOP (1) AmsVw_DeviceLevelBlockKey.DeviceKey, 
						BlockData.BlockKey, 
						BlockData.EventIdDay,
						BlockData.EventIdFraction, 
						EventLog.EventTime
		FROM  AmsVw_BlockTags INNER JOIN
		AmsVw_DeviceLevelBlockKey ON AmsVw_BlockTags.BlockKey = AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey INNER JOIN
		BlockData ON AmsVw_DeviceLevelBlockKey.BlockKey = BlockData.BlockKey INNER JOIN
		EventLog ON BlockData.EventIdDay = EventLog.EventIdDay AND BlockData.EventIdFraction = EventLog.EventIdFraction
		WHERE (AmsVw_BlockTags.AmsTag = @AmsTag) AND (EventLog.Type = 2) AND (EventLog.Category = 39) AND (BlockData.ParamKind = N'D')
		GROUP BY AmsVw_DeviceLevelBlockKey.DeviceKey, BlockData.BlockKey, BlockData.EventIdDay, BlockData.EventIdFraction, EventLog.EventTime
		ORDER BY BlockData.EventIdDay DESC, BlockData.EventIdFraction DESC	
	)
	,TempTable2 AS
	(
		--Get the calibration data for only the latest calibration event. (without other heavy baggages)
		SELECT TempTable1.DeviceKey,
				BlockData.EventIdDay, 
				BlockData.EventIdFraction, 
				TempTable1.EventTime,
				BlockData.ParamKind, 
				BlockData.ParamName, 
				BlockData.ParamDataType,
				BlockData.ParamDataSize, 		
				BlockData.ParamData 
		FROM TempTable1 INNER JOIN
		BlockData ON TempTable1.BlockKey = BlockData.BlockKey AND 
					 TempTable1.EventIdDay = BlockData.EventIdDay AND 
					 TempTable1.EventIdFraction = BlockData.EventIdFraction
		
	)
	--Now handle the narrow or (generic string and other data type) and hand out the result to the caller.
	SELECT  		
		TempTable2.EventIdDay, 
		TempTable2.EventIdFraction, 
		TempTable2.EventTime,
		TempTable2.ParamKind, 
		TempTable2.ParamName, 
		TempTable2.ParamDataType,
		TempTable2.ParamDataSize, 		
		convert(nvarchar(max), convert(varbinary(max), TempTable2.ParamData)) AS ParamData
	FROM TempTable2
	WHERE
		(TempTable2.ParamDataType = 12)		--Narrow string
	UNION
	SELECT  		
		TempTable2.EventIdDay, 
		TempTable2.EventIdFraction, 
		TempTable2.EventTime,
		TempTable2.ParamKind, 
		TempTable2.ParamName, 
		TempTable2.ParamDataType,
		TempTable2.ParamDataSize, 		
		TempTable2.ParamData
	FROM TempTable2
	WHERE
		(TempTable2.ParamDataType <> 12)	--Generic string (not just generic string but everything else)

END TRY
BEGIN CATCH
      set @nReturn = -1;  --General error
END CATCH

return @nReturn;

GO

