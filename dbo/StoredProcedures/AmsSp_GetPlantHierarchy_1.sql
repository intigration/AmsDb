
-----------------------------------------------------------------------
-- AmsSp_GetPlantHierarchy_1
--
-- Get the plant hierarchy.
--
-- Inputs -
--	none.
--
-- Outputs -
--	Recordset with the following --
--		Area
--		Unit
--		Equipment
--		Control
--
-- Returns -
--	returns number of records in recordset.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 07/30/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetPlantHierarchy_1
AS

declare @iReturnVal int
set @iReturnVal = 0

SELECT DISTINCT Area, Unit, Equipment, Control FROM AmsVw_AreaUnitEquipCntl
order by Area, Unit, Equipment, Control

declare @Err int, @Rowcount int
select @Err = @@ERROR, @Rowcount = @@ROWCOUNT

if (@Err <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = @Rowcount

return @iReturnVal

GO

