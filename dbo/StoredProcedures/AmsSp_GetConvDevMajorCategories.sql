-------------------------------------------------------
--
-- AmsSp_GetConvDevMajorCategories
--
--	Gets all of the Major categories associated
--	with conventional devices.
--
-- INPUTS:
--	NONE
--
-- OUPUTS:
--	Recordset containing all of the Major categories associated
--	with conventional devices.
--
-- AUTHOR:
--	Corey Middendorf
--	11/29/2004
----------------------------------------------------
CREATE PROCEDURE AmsSp_GetConvDevMajorCategories
AS
SELECT DISTINCT dbo.MajorDeviceCategories.Name AS MajorCategoryName
FROM         dbo.DeviceCategories INNER JOIN
                      dbo.MajorDeviceCategories ON dbo.DeviceCategories.MajorDeviceCategoryId = dbo.MajorDeviceCategories.MajorDeviceCategoryId INNER JOIN
                      dbo.DeviceRevisions ON dbo.DeviceCategories.DeviceCategoryId = dbo.DeviceRevisions.DeviceCategoryId INNER JOIN
                      dbo.DeviceTypes ON dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId INNER JOIN
                      dbo.MfrProtocols ON dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId INNER JOIN
                      dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId
WHERE     (dbo.MajorDeviceCategories.MajorDeviceCategoryId > 0) AND (dbo.DeviceProtocols.ProtocolId = 2)

GO

