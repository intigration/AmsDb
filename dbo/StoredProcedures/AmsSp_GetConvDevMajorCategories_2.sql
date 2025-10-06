-------------------------------------------------------
--
-- AmsSp_GetConvDevMajorCategories_2
--
--	Gets all of the Major categories associated
--	with conventional devices, and Minor categories are not NonDD.
--
-- INPUTS:
--	NONE
--
-- OUPUTS:
--	Recordset containing all of the Major categories associated
--	with conventional devices, and Minor categories are not NonDD.
--
-- AUTHOR:
--	Peter Nguyen
--	06/29/2012
----------------------------------------------------
CREATE PROCEDURE AmsSp_GetConvDevMajorCategories_2
AS
SELECT DISTINCT dbo.MajorDeviceCategories.Name AS MajorCategoryName
FROM         dbo.DeviceCategories INNER JOIN
                      dbo.MajorDeviceCategories ON dbo.DeviceCategories.MajorDeviceCategoryId = dbo.MajorDeviceCategories.MajorDeviceCategoryId INNER JOIN
                      dbo.MinorDeviceCategories ON dbo.DeviceCategories.MinorDeviceCategoryId = dbo.MinorDeviceCategories.MinorDeviceCategoryId INNER JOIN
                      dbo.DeviceRevisions ON dbo.DeviceCategories.DeviceCategoryId = dbo.DeviceRevisions.DeviceCategoryId INNER JOIN
                      dbo.DeviceTypes ON dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId INNER JOIN
                      dbo.MfrProtocols ON dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId INNER JOIN
                      dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId
WHERE     (dbo.MajorDeviceCategories.MajorDeviceCategoryId > 0) AND (dbo.MinorDeviceCategories.MinorDeviceCategoryId <> 83) AND (dbo.DeviceProtocols.ProtocolId = 2)

GO

