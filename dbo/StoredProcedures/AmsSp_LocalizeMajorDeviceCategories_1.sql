-----------------------------------------------------------------------
-- AmsSp_LocalizeMajorDeviceCategories_1
--
-- Localize the MajorDeviceCategories table
--
-- Inputs -
-- @nMajorDeviceCategoryId int
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
CREATE PROCEDURE AmsSp_LocalizeMajorDeviceCategories_1
@nMajorDeviceCategoryId int,
@sName nvarchar(255)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update MajorDeviceCategories set Name = @sName
		where MajorDeviceCategoryId = @nMajorDeviceCategoryId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

