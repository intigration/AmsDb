-----------------------------------------------------------------------
-- AmsSp_LocalizeLabels_1
--
-- Localize the Labels table
--
-- Inputs -
-- @nLabelId int
-- @sLabelName
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--
-- Junilo Pagobo - 06/24/2009
--
CREATE PROCEDURE AmsSp_LocalizeLabels_1
@nLabelId int,
@sLabelName nvarchar(255)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update Labels set LabelName = @sLabelName
		where LabelId = @nLabelId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

