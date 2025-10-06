----------------------------------------------------------------------------
-- AmsSp_GetCalibrationStatusByAmsTag
--
--	Gets Calibration Status of a certain AmsTag
-- 
-- Returns -
--	-1 - General error.
--
-- Enrico Resurreccion - 03/20/2012
CREATE PROCEDURE AmsSp_GetCalibrationStatusByAmsTag
@AmsTag nvarchar(256)
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY

	SELECT 
		CalStatus.DeviceKey,
		CalStatus.DevLastCalibrationDay,
		CalStatus.DevLastCalibrationFraction,
		dbo.AmsUdf_EventIdDayFractionToDateTime(CalStatus.DevLastCalibrationDay, CalStatus.DevLastCalibrationFraction) AS 'LastCalibrationDate',
		CalStatus.DevNextCalibrationDueDay,
		CalStatus.DevNextCalibrationDueFraction,
		dbo.AmsUdf_EventIdDayFractionToDateTime(CalStatus.DevNextCalibrationDueDay, CalStatus.DevNextCalibrationDueFraction) AS 'NextCalibrationDueDate',
		CalStatus.DevPassedLastCalibration
	FROM 
		CalStatus INNER JOIN Devices ON CalStatus.DeviceKey = Devices.DeviceKey
		INNER JOIN Blocks ON Devices.DeviceKey = Blocks.DeviceKey  
		INNER JOIN BlockAsgms ON Blocks.BlockKey = BlockAsgms.BlockKey  
		INNER JOIN ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
	WHERE (BlockAsgms.EventIdDayOut = '49710') AND (ExtBlockTags.ExtBlockTag = @AmsTag)


END TRY
BEGIN CATCH
      set @nReturn = -1;  --General error
END CATCH

return @nReturn;

GO

