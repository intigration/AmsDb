
-----------------------------------------------------------------------
-- AmsSp_DeviceTagLocation_1
--
-- Get device info along with database location and blockInfoAsXml.
-- Additionally gets the Major and Minor categories and the latest
--	descriptor parameter value.
--
-- Inputs -
-- 	@sSelectClause - select clause
--	@sWhereClause - where clause
--
-- Outputs -
--		(see temporary table column names.)
--
-- Returns -
--	returns 0 if successful.
--	-1 - if error.
--
-- Joe Fisher, 8/27/2003
--
-- ComQa22302 - changed sWhereClause to nText so that we can accept
-- very large filter statement (jdf).
--
--
CREATE PROCEDURE AmsSp_DeviceTagLocation_1
@sSelectClause nvarchar(2048),
@sWhereClause ntext
AS
declare @iReturnVal int
set @iReturnVal = 0


-- create the temporary table.devicekey, amsdevrevid, identifier
create table #AmsSp_DeviceTagLocation_1
(
	Manufacturer	nvarchar(255),
	MfrId		nvarchar(255),
	ProtocolId	int,
	Protocol	nvarchar(255),
	DeviceTypeCode	nvarchar(255),
	DeviceTypeName	nvarchar(255),
	DeviceRevisionCode nvarchar(255),
	DeviceRevisionName nvarchar(255),
	SerialNumber	nvarchar(255),
	ProtocolRevision nvarchar(50),
	AmsDeviceId	nvarchar(255),
	BlockKey	int,
	BlockIndex	int,
	DispositionId	smallint,
	DeviceDisposition nvarchar(255),
	Area		nvarchar(32),
	Unit		nvarchar(32),
	Equipment	nvarchar(32),
	Control		nvarchar(32),
	AmsTag		nvarchar(40),
	PlantServerId	nvarchar(255),
	PlantServerKey	int,
	BlockInfoAsXml	nvarchar(2048),
	SisDevice	nvarchar(2),
	MajorCategory	nvarchar(255),
	MinorCategory	nvarchar(255),
	DeviceDescription	nvarchar(255)
)

declare aCursor cursor for
	SELECT DISTINCT 
		TOP 100 PERCENT dbo.Manufacturers.Name AS Manufacturer, dbo.MfrProtocols.MfrId, dbo.DeviceProtocols.ProtocolId, 
		dbo.DeviceProtocols.Name AS Protocol, dbo.DeviceTypes.DeviceType AS DeviceTypeCode, dbo.DeviceTypes.Name AS DeviceTypeName, 
		dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, dbo.DeviceRevisions.Name AS DeviceRevisionName, 
		dbo.Devices.Identifier AS SerialNumber, dbo.Devices.ProtocolRevision, dbo.Devices.AmsDeviceId, dbo.Blocks.BlockKey, dbo.Blocks.BlockIndex, 
		dbo.Dispositions.DispositionId, dbo.Dispositions.Name AS DeviceDisposition, dbo.PlantServer.PlantServerId, dbo.PlantServer.PlantServerKey, 
		dbo.Devices.DeviceKey, dbo.Blocks.BlockType, dbo.AmsVw_BlockLocation.Area, dbo.AmsVw_BlockLocation.Unit, 
		dbo.AmsVw_BlockLocation.Equipment, dbo.AmsVw_BlockLocation.Control, dbo.AmsVw_CurrentTagBlockAsgms.AmsTag, 
		dbo.AmsUdf_GetFFBlockName(dbo.Blocks.BlockType, dbo.Blocks.BlockIndex) AS BlockName, dbo.DeviceLocation.SisStatus AS SisDevice, 
		dbo.MajorDeviceCategories.Name, dbo.MinorDeviceCategories.Name,
		dbo.AmsUdf_CurrentDescriptor(dbo.Blocks.BlockKey) AS DeviceDescription
	FROM	dbo.MajorDeviceCategories INNER JOIN
		dbo.DeviceCategories INNER JOIN
		dbo.DeviceRevisions INNER JOIN
		dbo.Devices ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId INNER JOIN
		dbo.DeviceTypes ON dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId INNER JOIN
		dbo.MfrProtocols ON dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId INNER JOIN
		dbo.Manufacturers ON dbo.MfrProtocols.AmsMfrNameId = dbo.Manufacturers.AmsMfrNameId INNER JOIN
		dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
		dbo.Blocks ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
		dbo.Dispositions ON dbo.Devices.DispositionId = dbo.Dispositions.DispositionId ON 
		dbo.DeviceCategories.DeviceCategoryId = dbo.DeviceRevisions.DeviceCategoryId INNER JOIN
		dbo.MinorDeviceCategories ON dbo.DeviceCategories.MinorDeviceCategoryId = dbo.MinorDeviceCategories.MinorDeviceCategoryId ON 
		dbo.MajorDeviceCategories.MajorDeviceCategoryId = dbo.DeviceCategories.MajorDeviceCategoryId LEFT OUTER JOIN
		dbo.AmsVw_CurrentTagBlockAsgms ON dbo.Blocks.BlockKey = dbo.AmsVw_CurrentTagBlockAsgms.BlockKey LEFT OUTER JOIN
		dbo.AmsVw_BlockLocation ON dbo.Blocks.BlockKey = dbo.AmsVw_BlockLocation.TableKey LEFT OUTER JOIN
		dbo.PlantServer INNER JOIN
		dbo.DeviceLocation ON dbo.PlantServer.PlantServerKey = dbo.DeviceLocation.PlantServerKey ON 
		dbo.Blocks.BlockKey = dbo.DeviceLocation.BlockKey
	WHERE	(dbo.Devices.DeviceKey <> - 1)
	ORDER BY	dbo.Devices.DeviceKey, dbo.Blocks.BlockKey


declare @Manufacturer	nvarchar(255)
declare @MfrId		nvarchar(255)
declare @ProtocolId	int
declare @Protocol	nvarchar(255)
declare @DeviceTypeCode	nvarchar(255)
declare @DeviceTypeName	nvarchar(255)
declare @DeviceRevisionCode nvarchar(255)
declare @DeviceRevisionName nvarchar(255)
declare @SerialNumber	nvarchar(255)
declare @ProtocolRevision nvarchar(50)
declare @AmsDeviceId	nvarchar(255)
declare @BlockKey	int
declare @BlockIndex	int
declare @DispositionId	smallint
declare @DeviceDisposition nvarchar(255)
declare @Area		nvarchar(32)
declare @Unit		nvarchar(32)
declare @Equipment	nvarchar(32)
declare @Control	nvarchar(32)
declare @AmsTag		nvarchar(40)
declare @PlantServerId	nvarchar(255)
declare @PlantServerKey	int
declare @BlockName	nvarchar(255)
declare @BlockInfoAsXml	nvarchar(2048)
declare @DeviceKey	int
declare @BlockType	nvarchar(1)
declare @SisDevice	nvarchar(2)
declare @MajorCategory	nvarchar(255)
declare @MinorCategory	nvarchar(255)
declare @DeviceDescription	nvarchar(255)

declare @FinalManufacturer	nvarchar(255)
declare @FinalMfrId		nvarchar(255)
declare @FinalProtocolId	int
declare @FinalProtocol	nvarchar(255)
declare @FinalDeviceTypeCode	nvarchar(255)
declare @FinalDeviceTypeName	nvarchar(255)
declare @FinalDeviceRevisionCode nvarchar(255)
declare @FinalDeviceRevisionName nvarchar(255)
declare @FinalSerialNumber	nvarchar(255)
declare @FinalProtocolRevision nvarchar(50)
declare @FinalAmsDeviceId	nvarchar(255)
declare @FinalBlockKey	int
declare @FinalBlockIndex	int
declare @FinalDispositionId	smallint
declare @FinalDeviceDisposition nvarchar(255)
declare @FinalArea		nvarchar(32)
declare @FinalUnit		nvarchar(32)
declare @FinalEquipment	nvarchar(32)
declare @FinalControl	nvarchar(32)
declare @FinalAmsTag		nvarchar(40)
declare @FinalPlantServerId	nvarchar(255)
declare @FinalPlantServerKey	int
declare @FinalSisDevice		nvarchar(2)
declare @FinalMajorCategory	nvarchar(255)
declare @FinalMinorCategory	nvarchar(255)
declare @FinalDeviceDescription	nvarchar(255)

declare @nPrevDeviceKey as int
declare @nCount as int
set @nCount = 0
set @nPrevDeviceKey = -999
set @BlockInfoAsXml = ''

open aCursor
fetch next from aCursor into 
	@Manufacturer,
	@MfrId,
	@ProtocolId,
	@Protocol,
	@DeviceTypeCode,
	@DeviceTypeName,
	@DeviceRevisionCode,
	@DeviceRevisionName,
	@SerialNumber,
	@ProtocolRevision,
	@AmsDeviceId,
	@BlockKey,
	@BlockIndex,
	@DispositionId,
	@DeviceDisposition,
	@PlantServerId,
	@PlantServerKey,
	@DeviceKey,
	@BlockType,
	@Area,
	@Unit,
	@Equipment,
	@Control,
	@AmsTag,
	@BlockName,
	@SisDevice,
	@MajorCategory,
	@MinorCategory,
	@DeviceDescription
while (@@fetch_status = 0)
begin
--print 'DeviceKey=' + convert(nvarchar(20), @DeviceKey) + ', Prev=' + convert(nvarchar(20), @nPrevDeviceKey)
	if (@DeviceKey = @nPrevDeviceKey)
	begin
		-- we have the same deviceKey as the previous, add BlockInfoAsXml stuff.
		-- we do not want the device-level stuff- ie. blockIndex of zero (0).
		if (@BlockIndex > 0)
		begin
			if (@nCount = 0)
			begin
				-- initiate the blockInfo xml
				set @BlockInfoAsXml = '<BlockInfo>'
			end
			if (@blockType ='R' or @blockType ='T')
			begin
				-- add the block element and its attributes.
				set @BlockInfoAsXml = @BlockInfoAsXml + '<Block Index="' + convert(nvarchar(20), @BlockIndex) + '"'
				set @BlockInfoAsXml = @BlockInfoAsXml + ' Type="' + @BlockType + '"'
				set @BlockInfoAsXml = @BlockInfoAsXml + ' Name="' + @BlockName + '"'
				set @BlockInfoAsXml = @BlockInfoAsXml + ' />'
				-- indicate number of blocks in this collection for this device.
				set @nCount = @nCount + 1
			end
		end
	end
	else
	begin
		-- we do not have the same deviceKey as the previous.
		-- if this is the first record in the series then by-pass the insert.
		if (@nPrevDeviceKey <> -999)
		begin
			-- check if we had multiple-block values.
			if (@nCount <> 0)
			begin
				-- terminate the blockInfo xml.
				set @BlockInfoAsXml = @BlockInfoAsXml + '</BlockInfo>'
			end

--print 'inserting into #AmsSp_DeviceTagLocation_1 blockKey- ' + convert(nvarchar(20), @FinalBlockKey)

			insert into #AmsSp_DeviceTagLocation_1 (Manufacturer,
					MfrId,
					ProtocolId,
					Protocol,
					DeviceTypeCode,
					DeviceTypeName,
					DeviceRevisionCode,
					DeviceRevisionName,
					SerialNumber,
					ProtocolRevision,
					AmsDeviceId,
					BlockKey,
					BlockIndex,
					DispositionId,
					DeviceDisposition,
					Area,
					Unit,
					Equipment,
					Control,
					AmsTag,
					PlantServerId,
					PlantServerKey,
					BlockInfoAsXml,
					SisDevice,
					MajorCategory,
					MinorCategory,
					DeviceDescription)
				values (@FinalManufacturer,
					@FinalMfrId,
					@FinalProtocolId,
					@FinalProtocol,
					@FinalDeviceTypeCode,
					@FinalDeviceTypeName,
					@FinalDeviceRevisionCode,
					@FinalDeviceRevisionName,
					@FinalSerialNumber,
					@FinalProtocolRevision,
					@FinalAmsDeviceId,
					@FinalBlockKey,
					@FinalBlockIndex,
					@FinalDispositionId,
					@FinalDeviceDisposition,
					@FinalArea,
					@FinalUnit,
					@FinalEquipment,
					@FinalControl,
					@FinalAmsTag,
					@FinalPlantServerId,
					@FinalPlantServerKey,
					@BlockInfoAsXml,
					@FinalSisDevice,
					@FinalMajorCategory,
					@FinalMinorCategory,
					@FinalDeviceDescription)
	
		end
	
		-- set up for new series.
		set @nCount = 0
		set @BlockInfoAsXml = ''
		set @nPrevDeviceKey = @DeviceKey

		-- we will be using 'captured' device-level information to put into temp table.
		if (@BlockIndex = 0)
		begin
			set @FinalManufacturer = @Manufacturer
			set @FinalMfrId = @MfrId
			set @FinalProtocolId = @ProtocolId
			set @FinalProtocol = @Protocol
			set @FinalDeviceTypeCode = @DeviceTypeCode
			set @FinalDeviceTypeName = @DeviceTypeName
			set @FinalDeviceRevisionCode = @DeviceRevisionCode
			set @FinalDeviceRevisionName = @DeviceRevisionName
			set @FinalSerialNumber = @SerialNumber
			set @FinalProtocolRevision = @ProtocolRevision
			set @FinalAmsDeviceId = @AmsDeviceId
			set @FinalBlockKey = @BlockKey
			set @FinalBlockIndex = @BlockIndex
			set @FinalDispositionId = @DispositionId
			set @FinalDeviceDisposition = @DeviceDisposition
			set @FinalArea = @Area
			set @FinalUnit = @Unit
			set @FinalEquipment = @Equipment
			set @FinalControl = @Control
			set @FinalAmsTag = @AmsTag
			set @FinalPlantServerId = @PlantServerId
			set @FinalPlantServerKey = @PlantServerKey
			set @FinalSisDevice = @SisDevice
			set @FinalMajorCategory = @MajorCategory
			set @FinalMinorCategory = @MinorCategory
			set @FinalDeviceDescription = @DeviceDescription
	end
	end
	fetch next from aCursor into 
		@Manufacturer,
		@MfrId,
		@ProtocolId,
		@Protocol,
		@DeviceTypeCode,
		@DeviceTypeName,
		@DeviceRevisionCode,
		@DeviceRevisionName,
		@SerialNumber,
		@ProtocolRevision,
		@AmsDeviceId,
		@BlockKey,
		@BlockIndex,
		@DispositionId,
		@DeviceDisposition,
		@PlantServerId,
		@PlantServerKey,
		@DeviceKey,
		@BlockType,
		@Area,
		@Unit,
		@Equipment,
		@Control,
		@AmsTag,
		@BlockName,
		@SisDevice,
		@MajorCategory,
		@MinorCategory,
		@DeviceDescription
end

-- if we had a record left over then we need to service it as well.
if (@nPrevDeviceKey <> -999)
begin
	-- check if we had multiple-block values.
	if (@nCount <> 0)
	begin
		-- terminate the blockInfo xml.
		set @BlockInfoAsXml = @BlockInfoAsXml + '</BlockInfo>'
	end
	insert into #AmsSp_DeviceTagLocation_1 (Manufacturer,
			MfrId,
			ProtocolId,
			Protocol,
			DeviceTypeCode,
			DeviceTypeName,
			DeviceRevisionCode,
			DeviceRevisionName,
			SerialNumber,
			ProtocolRevision,
			AmsDeviceId,
			BlockKey,
			BlockIndex,
			DispositionId,
			DeviceDisposition,
			Area,
			Unit,
			Equipment,
			Control,
			AmsTag,
			PlantServerId,
			PlantServerKey,
			BlockInfoAsXml,
			SisDevice,
			MajorCategory,
			MinorCategory,
			DeviceDescription)
		values (@FinalManufacturer,
			@FinalMfrId,
			@FinalProtocolId,
			@FinalProtocol,
			@FinalDeviceTypeCode,
			@FinalDeviceTypeName,
			@FinalDeviceRevisionCode,
			@FinalDeviceRevisionName,
			@FinalSerialNumber,
			@FinalProtocolRevision,
			@FinalAmsDeviceId,
			@FinalBlockKey,
			@FinalBlockIndex,
			@FinalDispositionId,
			@FinalDeviceDisposition,
			@FinalArea,
			@FinalUnit,
			@FinalEquipment,
			@FinalControl,
			@FinalAmsTag,
			@FinalPlantServerId,
			@FinalPlantServerKey,
			@BlockInfoAsXml,
			@FinalSisDevice,
			@FinalMajorCategory,
			@FinalMinorCategory,
			@FinalDeviceDescription)
end

close aCursor
deallocate aCursor

EXEC (@sSelectClause  +' from #AmsSp_DeviceTagLocation_1 ' +  @sWhereClause)

if (@@ERROR <> 0)
	set @iReturnVal = -1

drop table #AmsSp_DeviceTagLocation_1

if (@@ERROR <> 0)
	set @iReturnVal = -1

return @iReturnVal

GO

