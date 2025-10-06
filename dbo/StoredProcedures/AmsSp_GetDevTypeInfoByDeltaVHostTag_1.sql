
-----------------------------------------------------------------------
-- AmsSp_GetDevTypeInfoByDeltaVHostTag_1
--
-- Get device type info by current DeltaVHostName and DeltaVHostTag.
-- Note: get device having identStatus of 1.
--
-- Inputs -
--	sDeltaVHostName
--	sDeltaVHostTag	
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
--      -1 - device type info not found.
--	-2 - alarm block index not found.
--	-3 - general error.
--
-- Nghy Hong, 3/14/2006
-- Joe Fisher, 5/22/2006, SCR:AOEP00019246
--	Added IdentStatus = 1 as qualifier as there can be multiple devices
--	with the same HostTag on the same Host system.  But only one of these
--	devices should have an identStatus of 1.
--	If 0 devices or multiple devices then -1 is returned.
--
CREATE  PROCEDURE AmsSp_GetDevTypeInfoByDeltaVHostTag_1
@sDeltaVHostName		nvarchar(255),
@sDeltaVHostTag			nvarchar(256),
@sOutManufacturer		nvarchar(255) output,
@sOutProtocolName		nvarchar(255) output,
@nOutMfrId			int output,
@sOutDeviceTypeName		nvarchar(255) output,
@nOutDeviceTypeCode		int output,
@sOutDeviceRevisionName		nvarchar(255) output,
@nOutDeviceRevisionCode		int output,
@sOutSerialNumber 		nvarchar(255) output,
@nOutAlarmBlockIndex		int output 
AS
DECLARE @iReturnVal int
set @iReturnVal = 0

set nocount on

set @nOutAlarmBlockIndex = -999
declare @iAmsDevRevId int
-- go ahead and select based on supplied parameters

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
WHERE   (dbo.DeviceLocation.HostTag = @sDeltaVHostTag)
	AND (dbo.NetworkInfoProperty.NetworkInfoPropertyKey = N'DeltaVDB Server')
	AND (dbo.NetworkInfoProperty.NetworkInfoPropertyValue = @sDeltaVHostName)
	AND (dbo.DeviceLocation.IdentStatus = 1)

declare @Err int, @RCount int
-- Check for error and a record fetched
select @Err = @@ERROR, @RCount = @@ROWCOUNT
if (@Err <> 0)
begin
	PRINT 'Getting device type information failed'
	set @iReturnVal = -3
end
else
begin
	if (@RCount = 0)
	begin
		set @iReturnVal = -1
	end
	if (@RCount > 1)
	begin
		set @iReturnVal = -1
	end
end

-- Get AlarmBlockIndex if this is a FF Device Type
if (@sOutProtocolName = 'FF' and @iReturnVal = 0)
begin

  SELECT @nOutAlarmBlockIndex = dbo.AmsUdf_BinaryToInt(cast(dbo.NamedConfigData.ParamData as varbinary(4)))
  FROM  dbo.NamedConfigData INNER JOIN dbo.NamedConfigs ON dbo.NamedConfigData.ConfigKey = dbo.NamedConfigs.ConfigKey
  WHERE (dbo.NamedConfigData.ParamName = 'frsi.AlarmBlockIndex') AND (dbo.NamedConfigs.AmsDevRevId = @iAmsDevRevId)

  -- Check for error and a record fetched
  select @Err = @@ERROR, @RCount = @@ROWCOUNT
  if (@Err <> 0)
  begin
	PRINT 'Getting alarm block index failed'
	set @iReturnVal = -3
  end
  else
  begin
	if (@RCount = 0)
	begin
		set @iReturnVal = -2
	end
  end

end

return @iReturnVal

GO

