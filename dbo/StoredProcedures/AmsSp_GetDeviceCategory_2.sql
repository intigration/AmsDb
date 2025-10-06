----------------------------------------------------------------------
-- AmsSp_GetDeviceCategory_2
--
-- Get device category(Major/Minor) ID for the given Ams Tag
--
-- Inputs -
--	@sAmsTag nvarchar(255)	Ams device tag
-- Output -
--	@MajorDeviceCategoryId int	Device major category id.
--	@MinorDeviceCategoryId int	Device minor category id
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--  -2 - AmsTag not found in database
--
-- Nghy Hong 1/27/2012
--
CREATE PROCEDURE AmsSp_GetDeviceCategory_2
@sAmsTag nvarchar(255),
@MajorDeviceCategoryId int output,
@MinorDeviceCategoryId int output
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY

	if exists (select AmsTag from AmsVw_BlockTags where AmsVw_BlockTags.AmsTag = @sAmsTag)
	begin
		SELECT @MajorDeviceCategoryId = MajorDeviceCategories.MajorDeviceCategoryId, @MinorDeviceCategoryId = MinorDeviceCategories.MinorDeviceCategoryId
		FROM  DeviceRevisions INNER JOIN
               DeviceCategories ON DeviceRevisions.DeviceCategoryId = DeviceCategories.DeviceCategoryId INNER JOIN
               Devices ON DeviceRevisions.AmsDevRevId = Devices.AmsDevRevId INNER JOIN
               AmsVw_BlockTags INNER JOIN
               Blocks ON AmsVw_BlockTags.BlockKey = Blocks.BlockKey ON Devices.DeviceKey = Blocks.DeviceKey INNER JOIN
               MajorDeviceCategories ON DeviceCategories.MajorDeviceCategoryId = MajorDeviceCategories.MajorDeviceCategoryId INNER JOIN
               MinorDeviceCategories ON DeviceCategories.MinorDeviceCategoryId = MinorDeviceCategories.MinorDeviceCategoryId
		WHERE (AmsVw_BlockTags.AmsTag = @sAmsTag)
	end
	else
		set @nReturn = -2;

END TRY
BEGIN CATCH
	set @nReturn = -1;
END CATCH

RETURN @nReturn;

GO

