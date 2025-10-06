
-------------------------------------------------------------------------------
-- AmsSp_Operation_UpdateCalStatus_1 
--
-- Update device's calibration status.
-- 
-- Inputs --
--	@nBlockKey int - Device level database block key
--
-- Outputs --
--	None
--
-- Returns -
--	0 - successful
--  -1 - failed
--
-- Author --
--	Nghy Hong
--	9/25/06
--
CREATE PROCEDURE AmsSp_Operation_UpdateCalStatus_1
@nBlockKey int		--Device level BlockKey
AS
declare @iReturn int
set @iReturn = 0	--Successful

declare @nDeviceKey int
declare @nLastCalDay int
declare @nLastCalFraction int
declare @nNextCalDueDay int
declare @nNextCalDueFraction int
declare @bitPassedLastCalibratin bit

declare @nDefCalibrationInterval int
declare @nDefIntervalUnits int

declare @nProjectedDueDay int
declare @nProjectedDueFraction int

--Get DeviceKey
SELECT @nDeviceKey = Devices.DeviceKey
FROM   Blocks INNER JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey 
WHERE  (Blocks.BlockKey = @nBlockKey)

if (@@rowcount = 0)
begin
	print 'DeviceKey not found for BlockKey ' + convert(nvarchar(10), @nBlockKey)
	return -1
end

--Get the device calibration status
SELECT @nLastCalDay = CalStatus.DevLastCalibrationDay, 
	   @nLastCalFraction = CalStatus.DevLastCalibrationFraction, 
	   @nNextCalDueDay = CalStatus.DevNextCalibrationDueDay, 
	   @nNextCalDueFraction = CalStatus.DevNextCalibrationDueFraction, 
	   @bitPassedLastCalibratin = CalStatus.DevPassedLastCalibration
FROM   CalStatus 
WHERE  (CalStatus.DeviceKey = @nDeviceKey)

--If the device does not have a CalStatus record then create a default CalStatus
--else update its CalStatus.
if (@@rowcount = 0)
begin
	--Create a default CalStatus
	INSERT INTO CalStatus
				(DeviceKey, DevLastCalibrationDay, DevLastCalibrationFraction, 
				DevNextCalibrationDueDay, DevNextCalibrationDueFraction, DevPassedLastCalibration)
	VALUES     (@nDeviceKey, 0, 0, 0, 0, 0)
end
else
begin
	--Update CalStatus if last calibration was passed    1 => passed and 0 =>not passed
	if (@bitPassedLastCalibratin <> 0)
	begin
		--Get the current TestDefinition for this device block.
		SELECT @nDefCalibrationInterval = TestDefinition.DefCalibrationInterval, 
			   @nDefIntervalUnits = TestDefinition.DefIntervalUnits
		FROM   BlockAsgms INNER JOIN
			   ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey INNER JOIN
			   TestDefinition ON ExtBlockTags.TestDefinitionId = TestDefinition.TestDefinitionId
		WHERE  (BlockAsgms.BlockKey = @nBlockKey) AND 
			   (BlockAsgms.EventIdDayOut = 49710) AND 
			   (BlockAsgms.EventIdFractionOut = 0) 

		if (@@rowcount > 0)
		begin
			--Get the projected next calibration date
			exec @iReturn = AmsSp_Operation_GetProjectedCalibrationDate_1 @nLastCalDay,
																		  @nLastCalFraction,
																		  @nDefCalibrationInterval,
																		  @nDefIntervalUnits,
																		  @nProjectedDueDay output,
																		  @nProjectedDueFraction output

			--Update device CalStatus
			UPDATE CalStatus
			SET	   CalStatus.DevNextCalibrationDueDay = @nProjectedDueDay,
				   CalStatus.DevNextCalibrationDueFraction = @nProjectedDueFraction
			WHERE (CalStatus.DeviceKey = @nDeviceKey)
		end
		else
		begin
			print 'TestDefinition does not exist'
			return -1
		end
	end  
end

return @iReturn

GO

