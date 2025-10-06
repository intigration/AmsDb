----------------------------------------------------------------------------
-- AmsSp_GetDeviceList
--
--	Gets device information for a certain AmsTag excluding Profibus devices
-- 
--	
-- Returns -
--	-1 - General error.
--
-- Enrico Resurreccion - 03/20/2012
CREATE PROCEDURE AmsSp_GetDeviceInformationByTag
@AmsTag nvarchar(255)
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY


		SELECT 
			ExtBlockTags.ExtBlockTag AS AmsTag, 
			DeviceTypes.Name AS DeviceTypeName, 
			DeviceTypes.DeviceType AS DeviceTypeID, 
			MajorDeviceCategories.Name AS MajorCategory, 
			MinorDeviceCategories.Name AS MinorCategory, 
			DeviceRevisions.DeviceRevision, 
			Devices.Identifier AS SerialNumber, 
			Devices.ProtocolRevision AS ProtocolRevision, 
			Manufacturers.Name AS ManufacturerName, 
			MfrProtocols.MfrId AS ManufacturerID, 
			Devices.Identifier AS DeviceID, 
			DeviceProtocols.ProtocolId AS ProtocolID, 
			DeviceProtocols.Name AS ProtocolIDName, 
			Devices.AmsDeviceId AS AMSDeviceID, 
			AmsVw_BlockLocation.Area, 
			AmsVw_BlockLocation.Unit, 
			AmsVw_BlockLocation.Equipment, 
			AmsVw_BlockLocation.Control
		FROM  
			Manufacturers 
			INNER JOIN MfrProtocols ON Manufacturers.AmsMfrNameId = MfrProtocols.AmsMfrNameId 
			INNER JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId 
			INNER JOIN DeviceTypes ON MfrProtocols.MfrProtocolId = DeviceTypes.MfrProtocolId 
			INNER JOIN DeviceRevisions ON DeviceTypes.AmsDevTypeId = DeviceRevisions.AmsDevTypeId  
			INNER JOIN Devices ON DeviceRevisions.AmsDevRevId = Devices.AmsDevRevId  
			INNER JOIN Blocks ON Devices.DeviceKey = Blocks.DeviceKey  
			INNER JOIN BlockAsgms ON Blocks.BlockKey = BlockAsgms.BlockKey  
			INNER JOIN ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey  
			INNER JOIN DeviceCategories ON DeviceRevisions.DeviceCategoryId = DeviceCategories.DeviceCategoryId  
			INNER JOIN MajorDeviceCategories ON DeviceCategories.MajorDeviceCategoryId = MajorDeviceCategories.MajorDeviceCategoryId 
			INNER JOIN MinorDeviceCategories ON DeviceCategories.MinorDeviceCategoryId = MinorDeviceCategories.MinorDeviceCategoryId 
			LEFT OUTER JOIN AmsVw_BlockLocation ON Blocks.BlockKey = AmsVw_BlockLocation.TableKey
		WHERE 
			(BlockAsgms.EventIdDayOut = '49710')
			AND (DeviceProtocols.ProtocolId <> 4)
			AND (DeviceProtocols.ProtocolId <> 5)
			AND ExtBlockTags.ExtBlockTag = @AmsTag


END TRY
BEGIN CATCH
      set @nReturn = -1;  --General error
END CATCH

return @nReturn;

GO

