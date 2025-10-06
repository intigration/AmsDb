-----------------------------------------------------------------------
-- AmsSp_LocalizeMinorDeviceCategories_1
--
-- Localize the MinorDeviceCategories table
--
-- Inputs -
-- @nMinorDeviceCategoryId int
-- @sName
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--
-- Junilo Pagobo - 06/23/2009
--
CREATE PROCEDURE AmsSp_LocalizeMinorDeviceCategories_1
@nMinorDeviceCategoryId int,
@sName nvarchar(255)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update MinorDeviceCategories set Name = @sName
		where MinorDeviceCategoryId = @nMinorDeviceCategoryId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

