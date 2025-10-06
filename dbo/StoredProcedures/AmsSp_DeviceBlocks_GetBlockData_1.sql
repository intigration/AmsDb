
-----------------------------------------------------------------------
-- AmsSp_DeviceBlocks_GetBlockData_1
--
-- Note: for FF Server.
--
-- Get block configuration for a device-block and point-in-time (UTC).
--
-- Inputs -
--	@sDeviceID nvarchar(256)
--		the device identifier.
--	@iBlockIndex smallint
--		the block index.
--  @dGmtTime
--		point in time
--
-- Outputs -
--	ItemID
--		the ParamName
--	Value
--		the ParamData
--	EventTime
--		the latest configuration change GMT time for each parameter 
--
-- Returns -
--	returns the number of rows in the resultset.
--      -1 - Error, unable to get DeviceBlockID.
--
-- Joe Fisher, 06/24/2003
-- Kevin Mixter, 10/02/2003
--
CREATE PROCEDURE AmsSp_DeviceBlocks_GetBlockData_1
@strDeviceID nvarchar(256),
@iBlockIndex smallint,
@dGmtTime double precision
AS
DECLARE @iRowCount int
DECLARE @sErrorMsg nvarchar(256)
DECLARE @iBlockKey int

set nocount on

-- get DeviceBlockID.
EXEC @iBlockKey = AmsSp_DeviceBlocks_GetBlockKey_1 @strDeviceID, @iBlockIndex

IF (@iBlockKey < 0)
   BEGIN
	RETURN -1
   END

declare @iReturnVal int
set @iReturnVal = 0

declare @rsBlockKey	integer
declare @rsEventIdDay	integer
declare @rsEventIdFraction	integer
declare @rsParamKind	char(1)
declare @rsParamName	nvarchar(255)
declare @rsValueMode	char(1)
declare @rsParamDataType	tinyint
declare @rsParamDataSize	integer
declare @rsParamData	varchar(1024)
declare @rsArchived	bit
declare @rsEventTime	datetime
declare @nIdDay int
declare @nIdFrac int

declare @cValueMode char(1)
set @cValueMode = 'h'

-- calculate Event Id corresponding to point in time
set @nIdDay = dbo.AmsUdf_EventTimeAsDblToEventIdDay(@dGmtTime)
set @nIdFrac = dbo.AmsUdf_EventTimeAsDblToEventIdFraction(@dGmtTime)

-- create the temporary table.
create table #ConfigParams
(
	ItemId		nvarchar(255),
	Value		varchar(1024), --nvarchar(255)
	EventTime	datetime
)

-- Get the list of distinct Parameters for this block.
declare aCursor cursor for select distinct ParamName from BlockData where (BlockKey = @iBlockKey) and (ValueMode = @cValueMode) and (ParamKind = 'P')

-- now for each of the parameters scan the BlockData table for the single value that just less
-- than or equal to the point-in-time.
-- If no value is found for that parameter then the EventIdDay = -1, EventIdFraction = -1, and
-- the ParamData is set to 'NA'
declare @sParamName as nvarchar(255)
open aCursor
fetch next from aCursor into @sParamName
while (@@fetch_status = 0)
begin

	SELECT     TOP 1 @rsBlockKey = dbo.BlockData.BlockKey,
			 @rsEventIdDay = dbo.BlockData.EventIdDay,
   			 @rsEventIdFraction = dbo.BlockData.EventIdFraction,
			 @rsParamKind = dbo.BlockData.ParamKind,
			 @rsParamName = dbo.BlockData.ParamName, 
	                 @rsValueMode = dbo.BlockData.ValueMode,
			 @rsParamDataType = dbo.BlockData.ParamDataType,
			 @rsParamDataSize = dbo.BlockData.ParamDataSize,
			 @rsParamData = dbo.BlockData.ParamData,
			 @rsArchived = dbo.BlockData.Archived,
			 @rsEventTime = dbo.EventLog.EventTime
	FROM         dbo.BlockData INNER JOIN
	                      dbo.EventLog ON dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
	WHERE     (dbo.BlockData.ParamKind = 'P') AND
		  (dbo.BlockData.ValueMode = @cValueMode) AND
		  (dbo.BlockData.BlockKey = @iBlockKey) AND 
	          (dbo.BlockData.ParamName = @sParamName) AND
	          (((dbo.EventLog.EventIdDay = @nIdDay) AND (dbo.EventLog.EventIdFraction <= @nIdFrac)) OR
	            (dbo.EventLog.EventIdDay < @nIdDay))
	ORDER BY dbo.EventLog.EventIdDay DESC, dbo.EventLog.EventIdFraction DESC

	if (@@rowcount = 1)
	begin
		insert #ConfigParams (	ItemId, Value, EventTime)
		values	      ( @rsParamName,
				@rsParamData,
				@rsEventTime)
	end

	fetch next from aCursor into @sParamName
end	-- while on the aCursor fetch.

	-- send the accumulated recordset.
	select  		ItemId,
				Value,
				EventTime
		from #ConfigParams
		order by ItemId asc

-- cleanup
close aCursor
deallocate aCursor
drop table #ConfigParams

return @iReturnVal

errorHandler:
PRINT 'AmsSp_DeviceBlocks_GetBlockData_1: ' + @sErrorMsg
RETURN -1

GO

