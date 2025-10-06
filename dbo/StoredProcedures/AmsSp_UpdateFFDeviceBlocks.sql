-----------------------------------------------------------------------
-- AmsSp_UpdateFFDeviceBlocks
--
--	Update FF device instances with any additional blocks from the 
--	updated device templates that are installed via DDInstall.
--
--
-- Inputs --
--	None.
--
-- Recordset output with the following columns --  
--		MfrId int					-	Manufacturer Id
--		DeviceTypeCode int			-	Device type code
--		DeviceRevCode int			-	Device revsion code
--		AmsDevRevId int				-	Ams Device Revision Id (database key)
--		DeviceId nvarchar(255)		-	Device serial number
--		BlockIndex int				-	Block index
--		BlockType nvarchar(5)		-	Block type, (ie.. F for Function block)
--		OpsStatus int				-	0 = successful, otherwise -1 = failed
--
-- Nghy Hong, 3/19/2009
--
CREATE PROCEDURE AmsSp_UpdateFFDeviceBlocks
AS
DECLARE @AmsDevRevId int, @DeviceKey int, @BlockIndex int, @BlockType nvarchar(5), @BlkKey int;
DECLARE @MfrId int, @DevTypeCode int, @DevRevCode int, @DevId nvarchar(255);
DECLARE @LogTable Table(
	MfrId int,
	DeviceTypeCode int,
	DeviceRevCode int,
	AmsDevRevId int,
	DeviceId nvarchar(255),
	BlockIndex int,
	BlockType nvarchar(5),
	OpsStatus int					
);

BEGIN TRY
	--Fetch a list of devices configuration blocks 
	DECLARE aCursor CURSOR FOR
	SELECT DeviceRevisions.AmsDevRevId, Devices.DeviceKey, NamedConfigBlocks.BlockIndex, NamedConfigBlocks.BlockType,
		   MfrProtocols.MfrId, DeviceTypes.DeviceType, DeviceRevisions.DeviceRevision, Devices.Identifier
	FROM  DeviceRevisions INNER JOIN
		  DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId INNER JOIN
		  MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId INNER JOIN
		  Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId INNER JOIN
		  DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId INNER JOIN
		  Devices ON DeviceRevisions.AmsDevRevId = Devices.AmsDevRevId INNER JOIN
		  NamedConfigs ON DeviceRevisions.AmsDevRevId = NamedConfigs.AmsDevRevId INNER JOIN
		  NamedConfigBlocks ON NamedConfigs.ConfigKey = NamedConfigBlocks.ConfigKey
	WHERE (DeviceProtocols.Name = 'FF')AND (NamedConfigBlocks.BlockIndex <> 0);

	--Iterate thru the list
	OPEN aCursor
	FETCH NEXT FROM aCursor INTO @AmsDevRevId, @DeviceKey, @BlockIndex, @BlockType, @MfrId, @DevTypeCode, @DevRevCode, @DevId
	WHILE (@@fetch_status = 0)
	BEGIN
		--Update the existing device instances with the missing configuration blocks.
		IF NOT EXISTS (
			SELECT BlockKey, BlockIndex, BlockType
			FROM Blocks
			WHERE (DeviceKey = @DeviceKey) AND (BlockIndex = @BlockIndex) AND (BlockType = @BlockType)
		)
		BEGIN
			SELECT @BlkKey = max(BlockKey) + 1 from Blocks;

			INSERT Blocks WITH (ROWLOCK) (BlockKey, DeviceKey, BlockIndex, DispositionId, BlockType)
			VALUES (@BlkKey, @DeviceKey, @BlockIndex, 0, @BlockType);
			--Log succesful ops
			INSERT INTO @LogTable
			(MfrId, DeviceTypeCode, DeviceRevCode, AmsDevRevId, DeviceId, BlockIndex, BlockType, OpsStatus)
			VALUES (@MfrId, @DevTypeCode, @DevRevCode, @AmsDevRevId, @DevId, @BlockIndex, @BlockType, 0);
		END

		FETCH NEXT FROM aCursor INTO @AmsDevRevId, @DeviceKey, @BlockIndex, @BlockType, @MfrId, @DevTypeCode, @DevRevCode, @DevId;
	END

	CLOSE aCursor;
	DEALLOCATE aCursor;

END TRY
BEGIN CATCH
	--Log failed ops
	INSERT INTO @LogTable
	(MfrId, DeviceTypeCode, DeviceRevCode, AmsDevRevId, DeviceId, BlockIndex, BlockType, OpsStatus)
	VALUES (@MfrId, @DevTypeCode, @DevRevCode, @AmsDevRevId, @DevId, @BlockIndex, @BlockType, -1);
END CATCH

--Output log to caller
SELECT * FROM @LogTable

GO

