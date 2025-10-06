----------------------------------------------------------------------
-- AmsSp_GetDeviceCategory_1
--
-- Get device category(Major/Minor) for the given Ams Tag
--
-- Inputs -
--	@sAmsTag nvarchar(255)	Ams device tag
-- Output -
--	@sMajor nvarchar(255)	Device major category name.
--	@sMinor nvarchar(255)	Device minor category name
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--  -2 - AmsTag not found in database
--
-- Nghy Hong 1/27/2012
--
CREATE PROCEDURE AmsSp_GetDeviceCategory_1
@sAmsTag nvarchar(255),
@sMajor nvarchar(255) output,
@sMinor nvarchar(255) output
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY

	if exists (select AmsTag from AmsVw_BlockTags where AmsVw_BlockTags.AmsTag = @sAmsTag)
	begin
		SELECT @sMajor = MajorDeviceCategories.Name, @sMinor = MinorDeviceCategories.Name
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

