----------------------------------------------------------------------
-- AmsSp_NotifyQ_GenerateKey_1
--
-- Generate a key for the notification.
--
-- Inputs -
--  none.
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- Joe Fisher 9/20/2004
--
CREATE PROCEDURE AmsSp_NotifyQ_GenerateKey_1
@sNotifyKey nvarchar(50) output
AS

set nocount on

declare @nReturn int
set @nReturn = 0

-- generate a notifyQ key.
declare @nGetId int
declare @nRetryCt int
declare @nMaxRetryCt int
declare @stmpNotifyKey nvarchar(50)
set @nGetId = 0
set @nRetryCt = 0
set @nMaxRetryCt = 10
set @stmpNotifyKey = ''
while (@nGetId = 0) and (@nRetryCt < @nMaxRetryCt)
begin
	set @sNotifyKey =  convert(nvarchar, GETUTCDATE(), 121)
	-- make sure the key is unique in the table.
	select @stmpNotifyKey = NotifyKey from NotifyQ with (nolock)
	where NotifyKey = @sNotifyKey
	if (@stmpNotifyKey = null) or (@stmpNotifyKey = '')
	begin
		-- we have a unique id.
		set @nGetId = 1
	end
	else
	begin
		-- we have a duplicate.
		-- we don't want to have to get hung up here.
		set @nRetryCt = @nRetryCt + 1
--print 'duplicate notifyQKey (' + @sNotifyKey + '), retryct=' + cast(@nRetryCt as nvarchar(10))
		waitfor delay '00:00:00.01'
		set @stmpNotifyKey = ''
	end
end

if (@nRetryCt >= @nMaxRetryCt)
begin
	-- we were unable to generate a unique key.
	set @nReturn = -1
end

return @nReturn

GO

