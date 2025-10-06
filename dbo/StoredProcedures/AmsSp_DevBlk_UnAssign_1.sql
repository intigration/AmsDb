
-----------------------------------------------------------------------
-- AmsSp_DevBlk_UnAssign_1
--
-- Unassign device to the provided disposition status (i.e. spare or retired)
--
-- Note - Only allow to unassign an device from an assigned status to spare or retired,
--		  or from a spare to retired.
--
-- Inputs -
--	@nDevLevelBlockKey	-	device level blockKey.
--  @sDispositionId		-	Disposition Id (i.e. spare or retired)	
--
-- Outputs -
--	none
--	
--
-- Returns -
--	 0	- successful
--	-1	- error on UnAssigning device
--	-2	- (device is in DeviceMonitorList and polling is enabled) or 
--		  (device is in DeviceMonitorList but alertMonitor is disabled for the plantServer)
--	-3	- Error on getting device's alert status
--	-4	- Unexpected disposition value
--	-5	- Device is not assigned
--
-- Nghy Hong 07/17/2008
--
CREATE PROCEDURE AmsSp_DevBlk_UnAssign_1
@nDevLevelBlockKey int,
@sDispositionId nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0

-- Check if the device has dispostion of assigned or spare 
select distinct DispositionId from  AmsVw_DevTagDisposStatus_1
where ((BlockKey = @nDevLevelBlockKey) AND (DispositionId = 1)) --(1 meaning assigned)
   or ((BlockKey = @nDevLevelBlockKey) AND (DispositionId = 2)) --(1 meaning spare)

if (@@rowcount = 1)
begin
	-- Expect unassigned dispositionId value to be 2 (meaning spare) or 3 (meaning retired)
	if (@sDispositionId = '2') or (@sDispositionId = '3')
	begin
		declare @sAlertMonitorStatus nvarchar(255)
		exec @iReturnVal = AmsSp_DevBlk_GetAlertMonitorStatus_1 @nDevLevelBlockKey, @sAlertMonitorStatus OUTPUT

		if (@iReturnVal = 0)
		begin
			-- Check if the device is in the monitor list
			if (@sAlertMonitorStatus = '1')
			begin
				-- device is not in DeviceMonitorList, 
				-- procede with disposition unAssignment ops
				BEGIN TRAN -- start a transaction
				begin Try
					-- Update DispositionId in Devices table
					update Devices set DispositionId = @sDispositionId
					from Devices INNER JOIN Blocks on Devices.DeviceKey = Blocks.DeviceKey
					where (Blocks.BlockKey = @nDevLevelBlockKey)

					-- Delete device from Components table
					DELETE FROM Components WHERE (TableName = 'blocks') AND (TableKey = @nDevLevelBlockKey) AND (LabelId = 0)

					-- Every thing is a OK
					COMMIT TRAN
				end try
				begin catch
					-- Ops error
					set @iReturnVal = -1
					ROLLBACK TRAN
				end catch	
			end
			else
				-- device is in the poll list or alertMonitor is disabled.
				set @iReturnVal = -2
		end
		else
			-- Error on getting device's alert status 
			set @iReturnVal = -3
	end
	else
		-- Unexpected disposition value
		set @iReturnVal = -4
end
else
	-- Device is not assigned
	set @iReturnVal = -5

return @iReturnVal

GO

