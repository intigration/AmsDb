----------------------------------------------------------------------------
-- AmsSp_GetLatestTestResultByTag
--
--	Gets Latest Test Result of a certain AmsTag
-- 
-- Returns -
--	-1 - General error.
--
-- Enrico Resurreccion - 03/20/2012
CREATE PROCEDURE AmsSp_GetLatestTestResultByTag
@AmsTag nvarchar(256),
@BlockIndex int = 0
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY

      DECLARE @BlockKey int;           
      
      SELECT @BlockKey = AmsVw_DeviceLevelBlockKey.BlockKey
		FROM AmsVw_BlockTags INNER JOIN
			AmsVw_DeviceLevelBlockKey ON AmsVw_BlockTags.BlockKey = AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey
		WHERE (AmsVw_BlockTags.AmsTag = @AmsTag) AND (AmsVw_DeviceLevelBlockKey.BlockIndex = @BlockIndex);
      
      
		WITH TestResult AS
		(SELECT
			TOP 1
			@AmsTag as AmsTag,
			TR.TestResultId,
			TR.EventIdDay,
			TR.EventIdFraction,
			dbo.AmsUdf_EventIdDayFractionToDateTime(TR.EventIdDay, TR.EventIdFraction) AS EventTime,
			TR.BlockKey,
			TR.TechnicianId,
			U.UserName AS TechnicianName,
			TR.WorkOrder,
			TR.ServiceId,
			SR.ServiceDesc,
			TR.TestEquipmentId1,
			D1.AmsDeviceTag as TestEquipmentTag1,
			TR.TestEquipmentId2,
			D2.AmsDeviceTag as TestEquipmentTag2,
			TR.TestEquipmentId3,
			D3.AmsDeviceTag as TestEquipmentTag3,
			TR.TestEquipmentId4,
			D4.AmsDeviceTag as TestEquipmentTag4,
			TR.TemperatureStd,
			TR.AmbientTemperature,
			TR.AmbientTemperatureUnit,
			TR.NotificationLimit,
			TR.AdjustmentLimit,
			TR.MaxErrorLimit,
			TR.ZeroErrorLimit,
			TR.SpanErrorLimit,
			TR.LinearityErrorLimit,
			TR.HysteresisErrorLimit,
			TR.UseZeroError,
			TR.UseSpanError,
			TR.UseLinearityError,
			TR.UseHysteresisError,
			TR.ServiceNote,
			TR.Type,
			TR.TestResultData
		FROM 
			TestResults TR				
			INNER JOIN ServiceReasons SR ON SR.ServiceId = TR.ServiceId
			INNER JOIN Users U ON U.UserKey = TR.TechnicianId
			INNER JOIN Devices D1 ON TR.TestEquipmentId1 = D1.DeviceKey
			INNER JOIN Devices D2 ON TR.TestEquipmentId2 = D2.DeviceKey
			INNER JOIN Devices D3 ON TR.TestEquipmentId3 = D3.DeviceKey
			INNER JOIN Devices D4 ON TR.TestEquipmentId4 = D4.DeviceKey	
		WHERE 
			TR.BlockKey = @BlockKey 
			AND TR.Type = 99			
		ORDER BY TR.EventIdDay DESC, TR.EventIdFraction DESC),
		
		AFAL AS
		(SELECT
			AFAL.TestResultId,
			AFAL.TestResultAFALId,
			AFAL.TestResultAFALType,
			AFAL.MaxError,
			AFAL.ZeroError,
			AFAL.SpanError,
			AFAL.LinearityError,
			AFAL.HysteresisError,
			AFAL.InputLowerRangeValue,
			AFAL.InputUpperRangeValue,
			AFAL.InputRangeUnits,
			AFAL.OutputLowerRangeValue,
			AFAL.OutputUpperRangeValue,
			AFAL.OutputRangeUnits,
			AFAL.Relationship,
			AFAL.NumberOfTestPoints
		FROM
			TestResultAFAL AFAL),
		
		TestResultPoint AS
		(SELECT
				TestResultPoints.TestResultAFALId,
				TestResultPoints.TestResultPointId,
				TestResultPoints.Input,
				TestResultPoints.Output,
				TestResultPoints.Error
			FROM
				TestResultPoints)
		
			
		SELECT * 
		FROM TestResult, TestResultAFAL, TestResultPoint
		WHERE 
			TestResult.TestResultId = TestResultAFAL.TestResultId
		AND	TestResultPoint.TestResultAFALId = TestResultAFAL.TestResultAFALId
		FOR XML AUTO, TYPE, ROOT('Root')

END TRY
BEGIN CATCH
      set @nReturn = -1;  --General error
END CATCH

return @nReturn;

GO

