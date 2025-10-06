-----------------------------------------------------------------------
-- AmsSp_LocalizeEventCategories_1
--
-- Localize the EventCategories table
--
-- Inputs -
-- @nCategoryId int
-- @sCategoryDesc
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--
-- Junilo Pagobo - 06/24/2009
--
CREATE PROCEDURE AmsSp_LocalizeEventCategories_1
@nCategoryId int,
@sCategoryDesc nvarchar(255)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update EventCategories set CategoryDesc = @sCategoryDesc
		where Category = @nCategoryId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

