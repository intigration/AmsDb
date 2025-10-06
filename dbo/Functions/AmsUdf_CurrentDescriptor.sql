
-------------------------------------------------------------------------------
-- AmsUdf_CurrentDescriptor
--
-- Returns the current descriptor parameter for the device, does not work for FF Devices.
--
-- Inputs --
--	@nBlockKey - The block key for which to get the current software revision for.
--
-- Outputs --
--	Descriptor as nvarchar
--
-- Author --
--	Corey Middendorf
--	11/03/04
--  12/31/09 Nghy Hong for AOEP00032552 
--  04/09/2012 Added 'NonDDDeviceDescription' to the query filter for nonDD conventional devices
CREATE FUNCTION AmsUdf_CurrentDescriptor
(@nBlockKey int)  
RETURNS nvarchar(255)
AS  
BEGIN 
	declare @Return nvarchar(255)
	declare @ParamData varchar(255)
	declare @DataType int

	SELECT TOP 1 
			@ParamData = ParamData,
			@DataType = ParamDataType
	FROM	dbo.BlockData INNER JOIN
		dbo.EventLog ON dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
	WHERE (BlockData.ParamName = N'descriptor.000000A5.0000.0000') AND (BlockData.BlockKey = @nBlockKey) OR
          (BlockData.ParamName = N'NonDDDeviceDescription') AND (BlockData.BlockKey = @nBlockKey)
	ORDER BY dbo.EventLog.EventTime desc

	--AOEP00032552 because of localization, the data type of this parameter is now Generic(wide) string type, 
	--it was narrow string type, this function needs to handle both (narrow(= 3) or wide(= 12)) string type.
	if @DataType = 12
		set @Return = cast(cast(@ParamData as varbinary(255)) as nvarchar(255))
	else
		set @Return = @ParamData

	return @Return
END

GO

