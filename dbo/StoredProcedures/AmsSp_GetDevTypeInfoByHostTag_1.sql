-----------------------------------------------------------------------
-- AmsSp_GetDevTypeInfoByHostTag_1
--
-- Get device type info by current DeltaVHostName and DeltaVHostTag.
-- Note: get device having identStatus of 1.
--
-- Inputs -
--	@sHostName
--	@sHostTag	
--  @sHostTypeKey	this the key assigned to the HostName in fms.ini file,
--					for instance, 'DeltaVDB Server' for DeltaV database server, 
--					and 'OVATION_DB_SERVER' for Ovation database server
--
-- Outputs -
--	ManufacturerName
--	ProtocolName
--	MfrId
--	DeviceTypeName
--	DeviceTypeCode
--	DeviceRevisionName
--	DeviceRevisionCode
--	SerialNumber
--	AlarmBlockIndex		will be -999 if not a FF device type
--
-- Returns -
--	returns the number of rows in the resultset.
--  -1 - device type info not found.
--	-2 - alarm block index not found.
--	-3 - general error.
--
-- Nghy Hong, 4/20/2010
--
CREATE  PROCEDURE AmsSp_GetDevTypeInfoByHostTag_1
@sHostName				nvarchar(255),
@sHostTag				nvarchar(256),
@sHostTypeKey			nvarchar(255),
@sOutManufacturer		nvarchar(255) output,
@sOutProtocolName		nvarchar(255) output,
@nOutMfrId				int output,
@sOutDeviceTypeName		nvarchar(255) output,
@nOutDeviceTypeCode		int output,
@sOutDeviceRevisionName	nvarchar(255) output,
@nOutDeviceRevisionCode	int output,
@sOutSerialNumber 		nvarchar(255) output,
@nOutAlarmBlockIndex	int output 
AS
DECLARE @iReturnVal int
set @iReturnVal = 0

set nocount on

set @nOutAlarmBlockIndex = -999
declare @iAmsDevRevId int
-- go ahead and select based on supplied parameters

BEGIN TRY

	SELECT  @sOutManufacturer = dbo.Manufacturers.Name, 
		@nOutMfrId = dbo.MfrProtocols.MfrId, 
		@sOutProtocolName = dbo.DeviceProtocols.Name, 
		@sOutDeviceTypeName = dbo.DeviceTypes.Name, 
		@nOutDeviceTypeCode = dbo.DeviceTypes.DeviceType, 
		@sOutDeviceRevisionName = dbo.DeviceRevisions.Name, 
		@nOutDeviceRevisionCode = dbo.DeviceRevisions.DeviceRevision, 
		@iAmsDevRevId = dbo.DeviceRevisions.AmsDevRevId,
		@sOutSerialNumber = dbo.Devices.Identifier
	FROM    dbo.Manufacturers INNER JOIN
			dbo.MfrProtocols ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
			dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
			dbo.DeviceTypes ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
			dbo.DeviceRevisions ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId INNER JOIN
			dbo.Devices ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId INNER JOIN
			dbo.Blocks ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
			dbo.DeviceLocation ON dbo.Blocks.BlockKey = dbo.DeviceLocation.BlockKey INNER JOIN
			dbo.NetworkInfo ON dbo.DeviceLocation.NetworkInfoKey = dbo.NetworkInfo.NetworkInfoKey INNER JOIN
			dbo.NetworkInfoProperty ON dbo.NetworkInfo.NetworkInfoKey = dbo.NetworkInfoProperty.NetworkInfoKey
	WHERE   (dbo.DeviceLocation.HostTag = @sHostTag)
		AND (dbo.NetworkInfoProperty.NetworkInfoPropertyKey = @sHostTypeKey)
		AND (dbo.NetworkInfoProperty.NetworkInfoPropertyValue = @sHostName)
		AND (dbo.DeviceLocation.IdentStatus = 1)

	declare @RCount int
	-- Get record fetched count
	select @RCount = @@ROWCOUNT

	if (@RCount = 0 or @RCount > 1)
	begin
		set @iReturnVal = -1
	end

	-- Get AlarmBlockIndex if this is a FF Device Type
	if (@sOutProtocolName = 'FF' and @iReturnVal = 0)
	begin
		SELECT @nOutAlarmBlockIndex = dbo.AmsUdf_BinaryToInt(cast(dbo.NamedConfigData.ParamData as varbinary(4)))
		FROM  dbo.NamedConfigData INNER JOIN dbo.NamedConfigs ON dbo.NamedConfigData.ConfigKey = dbo.NamedConfigs.ConfigKey
		WHERE (dbo.NamedConfigData.ParamName = 'frsi.AlarmBlockIndex') AND (dbo.NamedConfigs.AmsDevRevId = @iAmsDevRevId)

		-- Get record fetched count
		select @RCount = @@ROWCOUNT
		if (@RCount = 0)
		begin
		  set @iReturnVal = -2
		end
	end

End TRY
BEGIN CATCH
	set @iReturnVal = -3;
	PRINT 'AmsSp_GetDevTypeInfoByHostTag_1: ' + ERROR_MESSAGE();
END CATCH;

return @iReturnVal

GO

