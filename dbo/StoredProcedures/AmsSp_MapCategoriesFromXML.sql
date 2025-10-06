
-------------------------------------------------------
--
-- AmsSp_MapCategoriesFromXML
--
--	Reads an input XML file and maps the device types 
--	(MrfId, DevTypeCode, DevRevCode) to a particular
-- 	combination of Major and Minor category.  Updates
--	all necessary tables.
--
-- INPUTS:
--	sXmlFile
--
-- OUPUTS:
--	Recordset containing all device types that had
--	an issue trying to import the information that
--	was stated in the input XML file.
--
-- AUTHOR:
--	Corey Middendorf
--	11/18/2004
----------------------------------------------------
CREATE PROCEDURE AmsSp_MapCategoriesFromXML 
@dataAsXML nvarchar(max)
AS
declare @hDoc int 

-- prep XML doc
exec sp_xml_preparedocument @hDoc OUTPUT, @dataAsXML

--Create table to store values until all information is known.
declare @CategoryMapping_Table TABLE(
	MfrId int,
	DevTypeCode int,
	DevRevCode int,
	MajorCategoryId int,
	MinorCategoryId int,
	AmsDevRevId int)

--Create error table to store device types that have issues
--This will be returned to the caller
declare @ErrorMapping_Table TABLE(
	MfrId int,
	DevTypeCode int,
	DevRevCode int,
	MajorCategoryId int,
	MinorCategoryId int,
	AmsDevRevId int)

--Extract Device Type (MrfId, DevTypeCode, DevRevCode)
--data and Category information (MajorCategory, 
--MinorCategory) out of XML file.
--NOTE: AmsDevRevId and DeviceCategoryId are not part
--	of the input XML file, they are placeholders
--	for values retrieved later on.
INSERT INTO @CategoryMapping_Table
SELECT *
FROM OPENXML(@hDoc, '/dataroot/A_Device', 2)
	WITH	(MfrId int		'MfrId',
	 	DevTypeCode int 	'DevTypeCode',
		DevRevCode int		'DevRevCode',
		MajorCategoryId int	'MajorCategory',
		MinorCategoryId int	'MinorCategory',
		AmsDevRevId int 	'AmsDevRevId')

--Find AmsDevRevId values for data sets above and update the column.
UPDATE	@CategoryMapping_Table
SET	AmsDevRevId = dbo.DeviceRevisions.AmsDevRevId
FROM	@CategoryMapping_Table t, 
	dbo.DeviceRevisions INNER JOIN
	dbo.DeviceTypes ON dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId INNER JOIN
	dbo.MfrProtocols ON dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId
WHERE	(dbo.MfrProtocols.MfrId = t.MfrId) AND 
	(dbo.DeviceTypes.DeviceType = t.DevTypeCode) AND 
	(dbo.DeviceRevisions.DeviceRevision = t.DevRevCode)

--Declare misc variables to use
declare @DeviceCategoryId int
declare @TempMajorId int
declare @TempMinorId int

--Create and open a cursor to walk through the table variable to do
--updates as needed
declare @MfrId int
declare @DevTypeCode int
declare @DevRevCode int
declare @MajorCategoryId int
declare @MinorCategoryId int
declare @AmsDevRevId int
declare aCursor cursor for
	SELECT	*
	FROM	@CategoryMapping_Table

--Open cursor and start iterating through records
open aCursor
fetch next from aCursor into
	@MfrId,
	@DevTypeCode,
	@DevRevCode,
	@MajorCategoryId,
	@MinorCategoryId,
	@AmsDevRevId
while (@@fetch_status = 0)
begin
	--Reset values of variables to null for next iteration
	set @TempMajorId = null
	set @TempMinorId = null
	set @DeviceCategoryId = null

	if (@AmsDevRevId is not null) --Device exists in database
	begin
		--Check to see if IDs exist in Major and Minor tables in database
		SELECT	@TempMajorId = MajorDeviceCategoryId
		FROM	dbo.MajorDeviceCategories
		WHERE	dbo.MajorDeviceCategories.MajorDeviceCategoryId = @MajorCategoryId

		SELECT @TempMinorId = MinorDeviceCategoryId
		FROM	dbo.MinorDeviceCategories
		WHERE	dbo.MinorDeviceCategories.MinorDeviceCategoryId = @MinorCategoryId

		--Check to see if Major ID exists in databse
		if (@TempMajorId is null)
		begin
			--Add record to error table and set Major Category ID to 0 (Unknown)
			INSERT INTO @ErrorMapping_Table
				(MfrId, DevTypeCode, DevRevCode, MajorCategoryId, MinorCategoryId, AmsDevRevId)
			values	(@MfrId, @DevTypeCode, @DevRevCode, @MajorCategoryId, @MinorCategoryId, @AmsDevRevId)
			set @MajorCategoryId = 0
			set @MinorCategoryId = 0
		end
		--Check to see if Minor ID exists in databse
		if (@TempMinorId is null)
		begin
			--Add record to error table and set Minor Category ID to 0 (Unknown)
			INSERT INTO @ErrorMapping_Table
				(MfrId, DevTypeCode, DevRevCode, MajorCategoryId, MinorCategoryId, AmsDevRevId)
			values	(@MfrId, @DevTypeCode, @DevRevCode, @MajorCategoryId, @MinorCategoryId, @AmsDevRevId)
			set @MajorCategoryId = 0
			set @MinorCategoryId = 0
		end

		--Check to see if row exists in table, if so return the DeviceCategoryId
		SELECT	@DeviceCategoryId = DeviceCategoryId
		FROM	dbo.DeviceCategories
		WHERE	dbo.DeviceCategories.MajorDeviceCategoryId = @MajorCategoryId AND
			dbo.DeviceCategories.MinorDeviceCategoryId = @MinorCategoryId

		--Check to see if a row already exists in the table
		if (@DeviceCategoryId is null)
		begin
			--Row did not exist so create the next ID value
			SELECT	@DeviceCategoryId = (MAX(DeviceCategoryId) + 1)
			FROM	dbo.DeviceCategories

			--Insert the new data into the DeviceCategories table
			INSERT INTO dbo.DeviceCategories 
				(DeviceCategoryId, MajorDeviceCategoryId, MinorDeviceCategoryId)
			values	(@DeviceCategoryId, @MajorCategoryId, @MinorCategoryId)
		end

		--Update the DeviceRevisions table with DeviceCategoryID
		UPDATE	dbo.DeviceRevisions
		SET	DeviceCategoryId = @DeviceCategoryId
		FROM	dbo.DeviceRevisions dr
		WHERE	dr.AmsDevRevId IN (SELECT dbo.DeviceRevisions.AmsDevRevId FROM dbo.DeviceRevisions
		INNER JOIN dbo.DeviceTypes ON dbo.DeviceRevisions.DeviceRevision = @DevRevCode 
		AND dbo.DeviceTypes.AMSDevTypeId = dbo.DeviceRevisions.AMSDevTypeId 
		AND dbo.DeviceTypes.DeviceType = @DevTypeCode
            INNER JOIN dbo.MfrProtocols ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId 
		AND dbo.MfrProtocols.MfrId = @MfrId )
		
	end
	
	--Get next item in cursor(from table)
	fetch next from aCursor into
		@MfrId,
		@DevTypeCode,
		@DevRevCode,
		@MajorCategoryId,
		@MinorCategoryId,
		@AmsDevRevId
end

--return all the rows in the error table
SELECT	*
FROM	@ErrorMapping_Table

-- cleanup
close aCursor
deallocate aCursor

-- unload XML doc
exec sp_xml_removedocument @hDoc

GO

