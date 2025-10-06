----------------------------------------------------------------------------
-- AmsSp_UpdateCalibrationStatus
--
--	Updates the CalibrationStatus of a certain AmsTag. 
--	If e record does not exist, a new CalibrationStatus record is inserted.
-- 
-- Returns -
--	-1 - General error.
--
-- Enrico Resurreccion - 03/20/2012
-- John Paul Restubog - 06/20/2012   Added support to cater saving of Last Calibration Date ONLY, Next Calibration Date ONLY or both depends on the specified parameters
CREATE PROCEDURE AmsSp_UpdateCalibrationStatus
@AmsTag nvarchar(255),
@LastCalibrationDate nvarchar(50) = NULL,
@NextCalibrationDueDate nvarchar(50) = NULL,
@PassedLastCalibration bit = NULL
AS
declare @nReturn int;
set @nReturn = 0;


BEGIN TRY
	--If both parameters are NULL it means we dont need to update the database.
	if((@LastCalibrationDate IS NULL OR @LastCalibrationDate = '') AND 
	(@NextCalibrationDueDate IS NULL OR @NextCalibrationDueDate = ''))
	begin
		return -1
	end
	
	declare @iReturn int
	DECLARE @IsDeviceExist bit
	DECLARE @HasLastCalDateInSqlQuery bit
	DECLARE @sqlQuery NVARCHAR(2000)
	DECLARE @sqlUpperClause NVARCHAR(1500)
	DECLARE @sqlLowerClause NVARCHAR(500)
	DECLARE @LastCalibrationDateEventIdDay int
	DECLARE @LastCalibrationDateEventIdFraction int
	DECLARE @NextCalibrationDueDateEventIdDay int
	DECLARE @NextCalibrationDueDateEventIdFraction int
	DECLARE @CurrentLastCalibDateEventIdDay int
	DECLARE @CurrentLastCalibDateEventIdFraction int
	
	SET @HasLastCalDateInSqlQuery = 0
	
	--Determine if an entry exist.
	SELECT @IsDeviceExist = COUNT(*)
	FROM 
		CalStatus INNER JOIN Devices ON CalStatus.DeviceKey = Devices.DeviceKey
		INNER JOIN Blocks ON Devices.DeviceKey = Blocks.DeviceKey
		INNER JOIN BlockAsgms ON Blocks.BlockKey = BlockAsgms.BlockKey
		INNER JOIN ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
	WHERE ExtBlockTags.ExtBlockTag = @AmsTag
	
	--Convert last calibration date to event id and event id fraction
	if (@LastCalibrationDate IS NOT NULL)
	begin		
		exec @iReturn =AmsSp_GenerateEventId_1 @LastCalibrationDate OUTPUT, @LastCalibrationDateEventIdDay OUTPUT,@LastCalibrationDateEventIdFraction OUTPUT
	end
	
	--Convert next calibration date to event id and event id fraction
	if (@NextCalibrationDueDate IS NOT NULL)
	begin		
		exec @iReturn =AmsSp_GenerateEventId_1 @NextCalibrationDueDate OUTPUT, @NextCalibrationDueDateEventIdDay OUTPUT,@NextCalibrationDueDateEventIdFraction OUTPUT
	end	
	
	--An entry is already in the database, construct an UPDATE clause.
	if (@IsDeviceExist = 1)
	begin
		SELECT @CurrentLastCalibDateEventIdDay = DevLastCalibrationDay, @CurrentLastCalibDateEventIdFraction = DevLastCalibrationFraction
		FROM 
			CalStatus INNER JOIN Devices ON CalStatus.DeviceKey = Devices.DeviceKey
			INNER JOIN Blocks ON Devices.DeviceKey = Blocks.DeviceKey
			INNER JOIN BlockAsgms ON Blocks.BlockKey = BlockAsgms.BlockKey
			INNER JOIN ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
		WHERE ExtBlockTags.ExtBlockTag = @AmsTag
		
		--Set the default values of the UPDATE SQL Statement
		SET @sqlUpperClause =	'UPDATE CalStatus SET '			
		SET @sqlLowerClause =
		' FROM 
			CalStatus INNER JOIN Devices ON CalStatus.DeviceKey = Devices.DeviceKey
			INNER JOIN Blocks ON Devices.DeviceKey = Blocks.DeviceKey
			INNER JOIN BlockAsgms ON Blocks.BlockKey = BlockAsgms.BlockKey
			INNER JOIN ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
		WHERE ExtBlockTags.ExtBlockTag = ''' + @AmsTag + ''''

		--Save the last calibration date if it is specified AND it is more recent than the last calibration date in the database.
		if (@LastCalibrationDate IS NOT NULL)
		begin			
			if ((@LastCalibrationDateEventIdDay > @CurrentLastCalibDateEventIdDay) OR
			   (@LastCalibrationDateEventIdDay = @CurrentLastCalibDateEventIdDay AND @LastCalibrationDateEventIdFraction > @CurrentLastCalibDateEventIdFraction))
			begin		
				SET @sqlUpperClause = @sqlUpperClause + 
				' DevLastCalibrationDay = ' + CONVERT(VARCHAR(11),@LastCalibrationDateEventIdDay) + ',' +
				' DevLastCalibrationFraction = ' + CONVERT(VARCHAR(11),@LastCalibrationDateEventIdFraction) + ',' +
				' DevPassedLastCalibration = ' + CONVERT(VARCHAR(1),@PassedLastCalibration)
				
				SET @HasLastCalDateInSqlQuery = 1
			end	
		end
		
		--Save the next calibration date if it is specified AND it is greater than the last calibration date in the database.
		if ((@NextCalibrationDueDate IS NOT NULL) AND
		   ((@NextCalibrationDueDateEventIdDay > @CurrentLastCalibDateEventIdDay) OR
		   (@NextCalibrationDueDateEventIdDay = @CurrentLastCalibDateEventIdDay AND @NextCalibrationDueDateEventIdFraction > @CurrentLastCalibDateEventIdFraction)))
		begin
			if (@HasLastCalDateInSqlQuery = 1)
			begin
				SET @sqlUpperClause = @sqlUpperClause + ',' 
			end
			
			SET @sqlUpperClause = @sqlUpperClause + 
			' DevNextCalibrationDueDay = ' + CONVERT(VARCHAR(11),@NextCalibrationDueDateEventIdDay) + ',' +
			' DevNextCalibrationDueFraction = ' + CONVERT(VARCHAR(11),@NextCalibrationDueDateEventIdFraction)			
		end
	end
	else --No entry in the database, construct an INSERT clause.
	begin	
		DECLARE @DeviceKey int
		--Set the default values of the INSERT SQL Statement
		SET @sqlUpperClause = 'INSERT INTO CalStatus (DeviceKey'
		SET @sqlLowerClause = ' VALUES (' + CONVERT(VARCHAR(11),@DeviceKey)
		
		SELECT 
			@DeviceKey = Devices.DeviceKey 
		FROM 
			Devices 
			INNER JOIN Blocks ON Devices.DeviceKey = Blocks.DeviceKey  
			INNER JOIN BlockAsgms ON Blocks.BlockKey = BlockAsgms.BlockKey  
			INNER JOIN ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey
		WHERE 
			ExtBlockTags.ExtBlockTag = @AmsTag
		
		--Save the last calibration date if it is specified
		if (@LastCalibrationDate IS NOT NULL)
		begin
			SET @sqlUpperClause = @sqlUpperClause + ', ' + 
			'DevLastCalibrationDay, DevLastCalibrationFraction, DevPassedLastCalibration'
			
			SET @sqlLowerClause = @sqlLowerClause + ', ' + 
			CONVERT(VARCHAR(11),@LastCalibrationDateEventIdDay) + ', ' +
			CONVERT(VARCHAR(11),@LastCalibrationDateEventIdFraction) + ', ' +
			CONVERT(VARCHAR(1),@PassedLastCalibration)
		end		
				
		--Save the next calibration date if it is specified
		if (@NextCalibrationDueDate IS NOT NULL)
		begin
			SET @sqlUpperClause = @sqlUpperClause + ', ' + 
			'DevNextCalibrationDueDay, DevNextCalibrationDueFraction'
			
			SET @sqlLowerClause = @sqlLowerClause + ', ' + 
			CONVERT(VARCHAR(11),@NextCalibrationDueDateEventIdDay) + ', ' +
			CONVERT(VARCHAR(11),@NextCalibrationDueDateEventIdFraction)
		end		
		
		SET @sqlUpperClause = @sqlUpperClause + ')'
		SET @sqlLowerClause = @sqlLowerClause + ')'
	end
	
	SET @sqlQuery = @sqlUpperClause + @sqlLowerClause
	PRINT @sqlQuery
	
	EXECUTE (@sqlQuery)

END TRY
BEGIN CATCH
      set @nReturn = -1;  --General error
END CATCH


return @nReturn;

GO

