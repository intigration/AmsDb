
CREATE PROCEDURE AmsSp_AddDeviceParam_1
@iBlockKey int,
@iEventIdDay int,
@iEventIdFraction int,
@sParamKind nchar(1),
@sParamName nvarchar(255),
@sValueMode nchar(1),
@iParamDataType int,
@iParamDataSize int,
@sParamData nvarchar(max),
@Archived nchar(1)
AS
declare @nReturn int;
set @nReturn = 0;
declare @sData varchar(max);
declare @iSize int;

BEGIN TRY
	if @iParamDataType = 12
	begin
		set @sData = convert(varbinary(max), @sParamData);
		set @iSize = len(@sData);
	end
	else
	begin
		set @sData = @sParamData;
		set @iSize = @iParamDataSize;
	end

	insert into BlockData
		(BlockKey, EventIdDay, EventIdFraction, ParamKind, ParamName, 
		ValueMode, ParamDataType, ParamDataSize, ParamData, Archived)
	values (@iBlockKey, @iEventIdDay, @iEventIdFraction, @sParamKind, @sParamName, 
		@sValueMode, @iParamDataType, @iSize, @sData, @Archived);

END TRY
BEGIN CATCH
	set @nReturn = -1;	
END CATCH

RETURN @nReturn;

GO

