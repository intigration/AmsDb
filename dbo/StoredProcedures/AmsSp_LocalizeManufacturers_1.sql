-----------------------------------------------------------------------
-- AmsSp_LocalizeManufacturers_1
--
-- Localize the Manufacturers table
--
-- Inputs -
-- @nAmsMfrNameId int
-- @sName
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--
-- Junilo Pagobo - 06/24/2009
--
CREATE PROCEDURE AmsSp_LocalizeManufacturers_1
@nAmsMfrNameId int,
@sName nvarchar(50)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update Manufacturers set Name = @sName
		where AmsMfrNameId = @nAmsMfrNameId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

