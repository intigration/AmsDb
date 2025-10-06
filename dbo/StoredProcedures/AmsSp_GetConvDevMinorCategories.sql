-------------------------------------------------------
--
-- AmsSp_GetConvDevMinorCategories
--
--	Gets all of the Minor categories associated
--	with the Major category name passed in.
--
-- INPUTS:
--	@strConvDevMajorCategory
--		- Major category name to find all
--		  associated minor categories for.
--
-- OUPUTS:
--	Recordset containing all Minor categories
--	associated with the Major category passed
--	in.
--
-- AUTHOR:
--	Corey Middendorf
--	11/29/2004
----------------------------------------------------
CREATE PROCEDURE dbo.AmsSp_GetConvDevMinorCategories
@strConvDevMajorCategory nvarchar(255)
AS
SELECT DISTINCT dbo.MinorDeviceCategories.Name AS MinorCategoryName
FROM         dbo.DeviceCategories INNER JOIN
                      dbo.MinorDeviceCategories ON dbo.DeviceCategories.MinorDeviceCategoryId = dbo.MinorDeviceCategories.MinorDeviceCategoryId INNER JOIN
                      dbo.DeviceRevisions ON dbo.DeviceCategories.DeviceCategoryId = dbo.DeviceRevisions.DeviceCategoryId INNER JOIN
                      dbo.DeviceTypes ON dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId INNER JOIN
                      dbo.MfrProtocols ON dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId INNER JOIN
                      dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
                      dbo.MajorDeviceCategories ON dbo.DeviceCategories.MajorDeviceCategoryId = dbo.MajorDeviceCategories.MajorDeviceCategoryId
WHERE     (dbo.DeviceProtocols.ProtocolId = 2) AND (dbo.MajorDeviceCategories.Name = @strConvDevMajorCategory)

GO

