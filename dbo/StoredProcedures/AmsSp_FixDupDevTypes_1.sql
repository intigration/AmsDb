CREATE PROCEDURE AmsSp_FixDupDevTypes_1
as
set nocount on

declare @sMessage nvarchar(255)
declare @nSuccess int
select @nSuccess = 0
declare @nReturn int
set @nReturn = 0

print N'Executing AmsSp_FixDupDevTypes_1.'
print N''

IF NOT EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')
	create table ##RepairDupDevTypeInfo
	(
		Message	nvarchar(256)	not null
	)
else
	delete ##RepairDupDevTypeInfo

-- gather up duplicate device types.
--
declare DupDevTypesListCursor CURSOR
STATIC FOR
SELECT  distinct mp1.MfrId as MfrId,
	dp1.Name as Protocol, 
	dt1.DeviceType AS DevTypeCode,
	dr1.DeviceRevision AS DevRevCode, 
	(select count(*) from dbo.MfrProtocols as mp2 INNER JOIN
                      dbo.DeviceTypes as dt2 ON mp2.MfrProtocolId = dt2.MfrProtocolId INNER JOIN
                      dbo.DeviceRevisions as dr2 ON dt2.AmsDevTypeId = dr2.AmsDevTypeId
		where (mp2.MfrId = mp1.MfrId)
			and (dt2.DeviceType = dt1.DeviceType)
			and (dr2.DeviceRevision = dr1.DeviceRevision)
			and (mp2.MfrProtocolId = mp1.MfrProtocolId)
			) as DupCt
FROM  dbo.MfrProtocols as mp1 INNER JOIN
      dbo.DeviceProtocols as dp1 ON mp1.ProtocolId = dp1.ProtocolId INNER JOIN
      dbo.DeviceTypes as dt1 ON mp1.MfrProtocolId = dt1.MfrProtocolId INNER JOIN
      dbo.DeviceRevisions as dr1 ON dt1.AmsDevTypeId = dr1.AmsDevTypeId
where   (dp1.Name <> N'Conventional')
	and (1 < (select count(*)from dbo.MfrProtocols as mp3 INNER JOIN
	                      dbo.DeviceTypes as dt3 ON mp3.MfrProtocolId = dt3.MfrProtocolId INNER JOIN
	                      dbo.DeviceRevisions as dr3 ON dt3.AmsDevTypeId = dr3.AmsDevTypeId
			where (mp3.MfrId = mp1.MfrId)
				and (dt3.DeviceType = dt1.DeviceType)
				and (dr3.DeviceRevision = dr1.DeviceRevision)
				and (mp3.MfrProtocolId = mp1.MfrProtocolId)
				))
order by mp1.MfrId, dt1.DeviceType, dr1.DeviceRevision
--
--
--
declare @sProtocol nvarchar(255)
declare @sMfrId nvarchar(255)
declare @sDevTypeCode nvarchar(255)
declare @sDevRevCode nvarchar(255)
declare @nDupCt int
--
open DupDevTypesListCursor
--
Fetch Next from DupDevTypesListCursor into @sMfrId,
					@sProtocol,
					@sDevTypeCode,
					@sDevRevCode,
					@nDupCt
--
declare @nDupDevTypeFixStatus int
--
while (@@fetch_status = 0)
begin
	-- process this duplicated device type.
	/*print ''
	print @sProtocol + N'.' + @sMfrId + N'.' + @sDevTypeCode + N'.' + @sDevRevCode + N' DupCt=' + cast(@nDupCt as nvarchar(10))*/
	
	exec @nDupDevTypeFixStatus = AmsSp_FixDupDevType_1 @sMfrId,
					@sProtocol,
					@sDevTypeCode,
					@sDevRevCode

	if @nDupDevTypeFixStatus <> 0
		select @nSuccess = 1

	-- get next duplicate in the list
	Fetch Next from DupDevTypesListCursor into @sMfrId,
						@sProtocol,
						@sDevTypeCode,
						@sDevRevCode,
						@nDupCt
end

-- cleanup
close DupDevTypesListCursor
deallocate DupDevTypesListCursor

if @nSuccess = 0
	begin
		SELECT @sMessage = N'Sucessfully fixed all duplicate device types.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = 0
	end
else
	begin
		SELECT @sMessage = N'not all duplicate device types were fixed.'
		IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')					
			insert into ##RepairDupDevTypeInfo values (@sMessage)
		set @nReturn = 1
	end

--log event into eventlog
declare @nEventIdDay int
declare @nEventIdFraction int
declare @strEventTimeAsGMT as nvarchar(50)
declare @iReturn int

set @strEventTimeAsGMT = N'NO_EVENTTIME'
exec @iReturn =AmsSp_GenerateEventId_1 @strEventTimeAsGMT OUTPUT, @nEventIdDay OUTPUT,@nEventIdFraction OUTPUT
print N'eventtime - ' + @strEventTimeAsGMT
print N'IdDay - ' + cast(@nEventIdDay as nvarchar)
print N'IDFract - ' + cast(@nEventIdFraction as nvarchar)
insert EventLog with (rowlock) (EventIDDay,
		 EventIdFraction,
		 EventTime,
		 UserKey,
		 ComputerId,
		 BlockKey,
        	 EventCode,
		 Source,
		 Type, 
		 Category, 
		 Description,
		 OtherBufLen, 
		 Other,
		 Archived,
		 MoreDetail)
values (@nEventIdDay, 
	@nEventIdFraction,
	@strEventTimeAsGMT,
	6,
	-1, 
	-1,
	0,
	N'AmsSp_FixDupDevTypes_1',
	3,
	18,
	N'Status = ' + cast(@nReturn as nvarchar(10)),
	0,
	N'',
	0,
	null)

IF EXISTS (SELECT N'x' FROM tempdb.sys.objects WHERE type = N'U' and NAME = N'##RepairDupDevTypeInfo')	
	begin			
		select * from ##RepairDupDevTypeInfo
		
		drop table ##RepairDupDevTypeInfo
	end

return @nReturn

GO

