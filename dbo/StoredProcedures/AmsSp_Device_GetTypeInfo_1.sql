
-----------------------------------------------------------------------
-- AmsSp_Device_GetTypeInfo_1
--
-- Note: for FF Server.
--
-- Get device type info.
--
-- Inputs -
--	@strDeviceID nvarchar(256)
--		the device identifier.
--
-- Outputs -
--	ConfigName
--	BlockIndex
--	BlockType
--	ItemID
--		the ParamName
--	Value
--		the ParamData as varbinary(4096)
--
-- Returns -
--	returns the number of rows in the resultset.
--      -1 - device type info not found.
--	-2 - general error.
--
-- Joe Fisher, 07/15/2003
-- Nghy Hong	08/15/2011		Include device type info from InstantiableConfigData
--
CREATE  PROCEDURE AmsSp_Device_GetTypeInfo_1
@strDeviceID nvarchar(256)
AS
DECLARE @iReturnVal int;
DECLARE @sConfigName nvarchar(256);

set nocount on

BEGIN TRY
	-- need to obtain the characteristics record namedConfig name based on
	-- the @strDeviceID's device type info.
	EXEC  @iReturnVal = AmsSp_Device_GetCharTemplateName_1 @strDeviceID, @sConfigName output
	if (@iReturnVal <> 0)
		return -1;

	-- now go ahead and get the characteristics record information.
	With T1
	AS
	(
	SELECT  Manufacturers.Name AS ManufacturerName, 
			MfrProtocols.MfrId as ManufacturerId,
			DeviceTypes.Name AS DeviceTypeName, 
			DeviceTypes.DeviceType AS DeviceTypeCode,
			DeviceRevisions.Name AS DeviceRevisionName,
			DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
			NamedConfigs.ConfigName,
			NamedConfigs.ConfigType,
			NamedConfigBlocks.BlockIndex,
			NamedConfigBlocks.BlockType, 
			NamedConfigData.ParamName AS ItemId,
			NamedConfigData.ParamDataType AS ValueType, 
			NamedConfigData.ParamDataSize AS ValueLength,
			cast(NamedConfigData.ParamData as varBinary(4096)) as Value
	FROM  NamedConfigBlocks with (nolock) INNER JOIN
		  NamedConfigData with (nolock) ON NamedConfigBlocks.ConfigKey = NamedConfigData.ConfigKey AND 
		  NamedConfigBlocks.BlockIndex = NamedConfigData.BlockIndex INNER JOIN
		  MfrProtocols with (nolock) INNER JOIN
		  DeviceTypes with (nolock) ON MfrProtocols.MfrProtocolId = DeviceTypes.MfrProtocolId INNER JOIN
		  DeviceRevisions with (nolock) ON DeviceTypes.AmsDevTypeId = DeviceRevisions.AmsDevTypeId INNER JOIN
		  NamedConfigs with (nolock) ON DeviceRevisions.AmsDevRevId = NamedConfigs.AmsDevRevId ON 
		  NamedConfigBlocks.ConfigKey = NamedConfigs.ConfigKey INNER JOIN
		  Manufacturers with (nolock) ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId
	WHERE     (NamedConfigs.ConfigName = @sConfigName) AND (NamedConfigs.ConfigType = 'C')
	Union
	SELECT Manufacturers.Name AS ManufacturerName, 
		   MfrProtocols.MfrId AS ManufacturerId, 
		   DeviceTypes.Name AS DeviceTypeName, 
		   DeviceTypes.DeviceType AS DeviceTypeCode, 
		   DeviceRevisions.Name AS DeviceRevisionName, 
		   DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
		   NamedConfigs.ConfigName, 
		   InstantiableConfigBlocks.ConfigType, 
		   InstantiableConfigBlocks.BlockIndex, 
		   InstantiableConfigBlocks.BlockType, 
		   InstantiableConfigData.ParamName AS ItemId, 
		   InstantiableConfigData.ParamDataType AS ValueType, 
		   InstantiableConfigData.ParamDataSize AS ValueLength, 
		   CAST(InstantiableConfigData.ParamData AS varBinary(4096)) AS Value
	FROM  InstantiableConfigData with (nolock) INNER JOIN
		  InstantiableConfigBlocks with (nolock) ON InstantiableConfigData.InstantiableBlockKey = InstantiableConfigBlocks.InstantiableBlockKey INNER JOIN
		  InstantiableBlockAsgms with (nolock) ON InstantiableConfigBlocks.InstantiableBlockKey = InstantiableBlockAsgms.InstantiableBlockKey INNER JOIN
		  Devices with (nolock) ON InstantiableConfigBlocks.DeviceKey = Devices.DeviceKey INNER JOIN
		  DeviceRevisions with (nolock) ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId INNER JOIN
		  DeviceTypes with (nolock) ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId INNER JOIN
		  MfrProtocols with (nolock) ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId INNER JOIN
		  NamedConfigs with (nolock) ON DeviceRevisions.AmsDevRevId = NamedConfigs.AmsDevRevId INNER JOIN
		  Manufacturers with (nolock) ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId
	GROUP BY InstantiableConfigData.ParamName, InstantiableConfigData.ParamDataType, InstantiableConfigData.ParamDataSize, 
		  CAST(InstantiableConfigData.ParamData AS varBinary(4096)), InstantiableConfigBlocks.BlockIndex, InstantiableConfigBlocks.BlockType, 
		  InstantiableConfigBlocks.ConfigType, InstantiableBlockAsgms.UtcDateTimeOut, MfrProtocols.MfrId, DeviceTypes.Name, DeviceRevisions.Name, 
		  DeviceRevisions.DeviceRevision, NamedConfigs.ConfigName, Manufacturers.Name, DeviceTypes.DeviceType
	HAVING (InstantiableBlockAsgms.UtcDateTimeOut = CONVERT(DATETIME2, '9999-12-31 00:00:00', 102)) AND 
		   (InstantiableConfigBlocks.ConfigType = N'C') AND 
		   (NamedConfigs.ConfigName = @sConfigName)
	)
	SELECT * from T1;

	set @iReturnVal = @@ROWCOUNT
END TRY
BEGIN CATCH
	PRINT 'AmsSp_Device_GetTypeInfo_1: ' + ERROR_MESSAGE()
	set @iReturnVal = -2;
END CATCH

return @iReturnVal;

GO

