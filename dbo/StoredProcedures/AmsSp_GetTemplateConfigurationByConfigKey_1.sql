
-----------------------------------------------------------------------
-- AmsSp_GetTemplateConfigurationByConfigKey_1
--
-- Get configuration for a template by ConfigKey database key.
--
-- Inputs -
--	nConfigKey	integer		the ConfigKey.
--
-- Outputs -
--	Recordset containing list parameters for that point in time.
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 03/6/02
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetTemplateConfigurationByConfigKey_1
@nConfigKey as integer
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

declare @rsConfigKey	integer
declare @rsEventIdDay	integer
declare @rsEventIdFraction	integer
declare @rsParamKind	char(1)
declare @rsParamName	nvarchar(255)
declare @rsParamDataType	tinyint
declare @rsParamDataSize	integer
declare @rsParamData	varchar(255)
declare @rsArchived	bit

-- create the temporary table.
create table #ConfigParams
(
	ConfigKey	integer,
	EventIdDay	integer,
	EventIdFraction	integer,
	ParamKind	char(1),
	ParamName	nvarchar(255),
	ParamDataType	tinyint,
	ParamDataSize	integer,
	ParamData	varbinary(255) --nvarchar(255)
)

-- Get the list of distinct Parameters for this block.
declare aCursor cursor for select distinct ParamName from NamedConfigData where (ConfigKey = @nConfigKey) and (ParamKind = 'P')

-- now for each of the parameters scan the BlockData table for the single value that just less
-- than or equal to the point-in-time.
-- If no value is found for that parameter then the EventIdDay = -1, EventIdFraction = -1, and
-- the ParamData is set to 'NA'
declare @sParamName as nvarchar(255)
open aCursor
fetch next from aCursor into @sParamName
while (@@fetch_status = 0)
begin

	SELECT     TOP 1 @rsConfigKey = dbo.NamedConfigData.ConfigKey,
			 @rsEventIdDay = dbo.NamedConfigData.EventIdDay,
   			 @rsEventIdFraction = dbo.NamedConfigData.EventIdFraction,
			 @rsParamKind = dbo.NamedConfigData.ParamKind,
			 @rsParamName = dbo.NamedConfigData.ParamName, 
			 @rsParamDataType = dbo.NamedConfigData.ParamDataType,
			 @rsParamDataSize = dbo.NamedConfigData.ParamDataSize,
			 @rsParamData = dbo.NamedConfigData.ParamData,
			 @rsArchived = dbo.NamedConfigData.Archived
	FROM         dbo.NamedConfigData INNER JOIN
	                      dbo.EventLog ON dbo.NamedConfigData.EventIdDay = dbo.EventLog.EventIdDay AND dbo.NamedConfigData.EventIdFraction = dbo.EventLog.EventIdFraction
	WHERE     (dbo.NamedConfigData.ParamKind = 'P') AND
		  (dbo.NamedConfigData.ConfigKey = @nConfigKey) AND 
	          (dbo.NamedConfigData.ParamName = @sParamName)
	ORDER BY dbo.EventLog.EventIdDay DESC, dbo.EventLog.EventIdFraction DESC

	if (@@rowcount = 1)
	begin
		insert #ConfigParams (	ConfigKey,
				EventIdDay,
				EventIdFraction,
				ParamKind,
				ParamName,
				ParamDataType,
				ParamDataSize,
				ParamData)
		values	      ( @rsConfigKey,
				@rsEventIdDay,
				@rsEventIdFraction,
				@rsParamKind,
				@rsParamName,
				@rsParamDataType,
				@rsParamDataSize,
				cast(@rsParamData as varbinary(255)))
	end

	fetch next from aCursor into @sParamName
end	-- while on the aCursor fetch.

	select  		ConfigKey,
				EventIdDay,
				EventIdFraction,
				ParamKind,
				ParamName,
				ParamDataType,
				ParamDataSize,
				ParamData
		from #ConfigParams
		order by ParamName asc

-- cleanup
close aCursor
deallocate aCursor
drop table #ConfigParams

return @iReturnVal

GO

