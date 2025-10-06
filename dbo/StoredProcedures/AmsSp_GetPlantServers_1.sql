
-----------------------------------------------------------------------
-- AmsSp_GetPlantServers_1
--
-- Get the list of plant servers.
--
-- Inputs -
--	none.
--
-- Outputs -
--	Recordset with the following --
--		PlantServerId
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
CREATE PROCEDURE AmsSp_GetPlantServers_1
AS

declare @iReturnVal int
set @iReturnVal = 0

SELECT DISTINCT PlantServerId FROM PlantServer

declare @Err int, @RCount int
select @Err = @@ERROR, @RCount = @@ROWCOUNT

if (@Err <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = @RCount

return @iReturnVal

GO

