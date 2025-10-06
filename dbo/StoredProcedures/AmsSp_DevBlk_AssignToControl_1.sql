-----------------------------------------------------------------------
-- AmsSp_DevBlk_AssignToControl_1
--
-- Assign device to the provided control module.
--
-- Note - Expect control module already existed.
--
-- Inputs -
--	@nDevLevelBlockKey	-	device level blockKey.
--  @sArea				-	Area part of the control module path.	
--	@sUnit				-	Unit part of the control module path.
--	@sEquip				-	Equipment part of the control module path.
--	@sControl			-	Control part of the control module path.
--
-- Outputs -
--	none
--	
--
-- Returns -
--	 0	- successful
--	-1	- error 
--	-2  - Device already is assigned to a control area
--	-3	- Control path does not exist
--
-- Nghy Hong 07/18/2008
--
CREATE PROCEDURE AmsSp_DevBlk_AssignToControl_1
@nDeviceLevelBlockKey	int,
@sArea nvarchar(1024),
@sUnit nvarchar(1024),
@sEquip nvarchar(1024),
@sControl nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0

declare @iAreaId int

-- Check if the control path exists
select @iAreaId = AreaId from AmsVw_AreaUnitEquipCntl
where (Area = @sArea) AND (Unit = @sUnit) AND (Equipment = @sEquip) AND (Control = @sControl)

if (@@rowcount = 1)
begin
	-- Control path exists, now check if the device is assigned to any control area
	select TableName, TableKey, AreaId, LabelId from Components
	where  (TableName = 'Blocks') AND (TableKey = @nDeviceLevelBlockKey)

	if (@@rowcount = 0)
	begin
		-- Device is not assigned to any control area
		BEGIN TRAN -- start a transaction
		begin Try
			-- Update DispositionId in Devices table
			update Devices set DispositionId = 1 --(1 meaning assigned)
			from Devices INNER JOIN Blocks on Devices.DeviceKey = Blocks.DeviceKey
			where (Blocks.BlockKey = @nDeviceLevelBlockKey)
			
			-- Assign device to an control area
			insert into Components (TableName, TableKey, AreaId, LabelId)
			values ('Blocks',@nDeviceLevelBlockKey,@iAreaId,0)

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
		-- Error:  Device already is assigned to a control area
		set @iReturnVal = -2
end
else
	-- Control path does not exist
	set @iReturnVal = -3

return @iReturnVal

GO

