-------------------------------------------------------------------------------
-- AmsSp_Operation_GetProjectedCalibrationDate_1 
--
-- Get the projected calibration due date from the given last calibration date, 
-- calibration interval and interval unit.
--
-- Inputs --
--	@nLastCalibrationDay int - Day part of the last calibration date.
--  @nLastCalibrationFraction int - Fraction part of the last calibration date.
--  @nDefCalibrationInterval int - Calibration interval
--  @nDefIntervalUnits int - Calibratin interval frequency unit definition
--							- 0 => none, 1 => days, 2 => weeks, 3 => months, 4 => years
--
-- Outputs --
--	@nProjectedDueDay int - Day part of the Projected calibration due date.
--  @nProjectedDueFraction int - Fraction part of the Projected calibration due date.
--
-- Returns -
--	0 - successful
--  -1 - failed
--
-- Author --
--	Nghy Hong
--	9/25/06
--
CREATE PROCEDURE AmsSp_Operation_GetProjectedCalibrationDate_1
@nLastCalibrationDay int,
@nLastCalibrationFraction int,
@nDefCalibrationInterval int,
@nDefIntervalUnits int,
@nProjectedDueDay int output,
@nProjectedDueFraction int output		
AS
declare @iReturn int
set @iReturn = 0	--Successful

--declare @sGmtEventTime nvarchar(50)
declare @dtLastCalDate as datetime
declare @sGmtEventTime nvarchar(50)

--Validate last calibration date
if ( @nLastCalibrationDay >= 49710 or @nLastCalibrationDay <= 25569 )
begin
	--Last calibration date is invalid
	if @nDefIntervalUnits = 0	--Check if calibration interval frequency = none
	begin
		--Set next calibration due to none
		set @nProjectedDueDay = 0
		set @nProjectedDueFraction = 0
	end
	else
	begin
		--Set next calibration due date to today date in GMT
		set @sGmtEventTime = 'NO_EVENTTIME'
		exec @iReturn = AmsSp_GenerateEventId_1 @sGmtEventTime OUTPUT, 
												@nProjectedDueDay OUTPUT,
												@nProjectedDueFraction OUTPUT
		if (@iReturn <> 0) 
		begin
			return -1
		end
	end
end
else
begin
	if @nDefIntervalUnits = 1  --calibration interval frequency = days
	begin
		set @nProjectedDueDay = @nLastCalibrationDay + @nDefCalibrationInterval
		set @nProjectedDueFraction = @nLastCalibrationFraction
	end
	else if @nDefIntervalUnits = 2  --calibration interval frequency = weeks
	begin
		set @nProjectedDueDay = @nLastCalibrationDay + (@nDefCalibrationInterval * 7)
		set @nProjectedDueFraction = @nLastCalibrationFraction
	end
	else if @nDefIntervalUnits = 3  --calibration interval frequency = months
	begin
		set @dtLastCalDate = dbo.AmsUdf_EventIdDayFractionToDateTime(@nLastCalibrationDay, @nLastCalibrationFraction)
		print 'Prior calling DateAdd function:  ' + convert(nvarchar, @dtLastCalDate, 121)

		set @dtLastCalDate = dateadd(month, @nDefCalibrationInterval, @dtLastCalDate)
		set @sGmtEventTime = convert(nvarchar, @dtLastCalDate, 121)
		print 'After calling DateAdd function:  ' +  @sGmtEventTime

		exec @iReturn = AmsSp_GenerateEventId_1 @sGmtEventTime OUTPUT, 
												@nProjectedDueDay OUTPUT,
												@nProjectedDueFraction OUTPUT
		print 'After calling AmsSp_GenerateEventId_1 stored procedure:  ' +  @sGmtEventTime
	end
	else if @nDefIntervalUnits = 4  --calibration interval frequency = years
	begin
		set @dtLastCalDate = dbo.AmsUdf_EventIdDayFractionToDateTime(@nLastCalibrationDay, @nLastCalibrationFraction)
		print 'Prior calling DateAdd function:  ' + convert(nvarchar, @dtLastCalDate, 121)

		set @dtLastCalDate = dateadd(year, @nDefCalibrationInterval, @dtLastCalDate)
		set @sGmtEventTime = convert(nvarchar, @dtLastCalDate, 121)
		print 'After calling DateAdd function:  ' +  @sGmtEventTime

		exec @iReturn = AmsSp_GenerateEventId_1 @sGmtEventTime OUTPUT, 
												@nProjectedDueDay OUTPUT,
												@nProjectedDueFraction OUTPUT
		print 'After calling AmsSp_GenerateEventId_1 stored procedure:  ' +  @sGmtEventTime
	end
	else  --No calibration frequency 
	begin
		--Set next calibration due to none
		set @nProjectedDueDay = 0
		set @nProjectedDueFraction = 0
	end
end

if @nProjectedDueDay >= 49710
begin
	set @nProjectedDueDay = 49710 - 1
	set @nProjectedDueFraction = @nLastCalibrationFraction
end

return @iReturn

GO

