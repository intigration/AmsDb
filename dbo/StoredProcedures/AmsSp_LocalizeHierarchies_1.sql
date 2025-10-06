-----------------------------------------------------------------------
-- AmsSp_LocalizeHierarchies_1
--
-- Localize the Hierarchies table
--
-- Inputs -
-- @nAreaId int
-- @sAreaName
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--
-- Junilo Pagobo - 06/24/2009
--
CREATE PROCEDURE AmsSp_LocalizeHierarchies_1
@nAreaId int,
@sAreaName nvarchar(32)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update Hierarchies set AreaName = @sAreaName
		where AreaId = @nAreaId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

