-----------------------------------------------------------------------
-- AmsSp_DevBlk_MoveSnapOnData_1
--
-- Move SnapOnData from one device to another device
--
--
-- Inputs -
--	@nDevLevelBlockKey	-	device level blockKey.  (Device where SnapOnData is moved to)
--  @sFromAmsTag		-	Ams tag  (Device where SnapOnData is moved from)
--
-- Outputs -
--	none
--	
--
-- Returns -
--	 0	- successful
--	-1	- error 
--
-- Nghy Hong 07/21/2008
--
CREATE PROCEDURE AmsSp_DevBlk_MoveSnapOnData_1
@nDevLevelBlockKey int,
@sFromAmsTag nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0

declare @iFromDevLevelBlkkey int

begin try
	select @iFromDevLevelBlkkey = BlockKey
	from  AmsVw_BlockTags 
	where (AmsTag  = @sFromAmsTag)

	if (@@rowcount = 1)
	begin
		UPDATE SnapOnData SET BlockKey = @nDevLevelBlockKey WHERE (BlockKey = @iFromDevLevelBlkkey)
	end
	else
		-- Device not found
		set @iReturnVal = -1
end try
begin catch
	-- other error
	set @iReturnVal = -1
end catch

return @iReturnVal

GO

