----------------------------------------------------------------------
-- AmsSp_NotifyQ_Pop_1
--
-- Pop a notification from the notifyQ.
--
-- Inputs -
--  none.
--
-- Outputs -
--  NotifyKey nvarchar(50) - the notification key value.
--	NotifyType int - the type of notification.
--  NotifyData nvarchar(1024) - the notification data.
--
-- Returns -
--	0 if no notifications present else 1.
--
-- Joe Fisher 9/20/2004
--
CREATE PROCEDURE AmsSp_NotifyQ_Pop_1
@sNotifyKey nvarchar(50) output,
@nNotifyType int output,
@sNotifyData nvarchar(max) output
AS

set nocount on

declare @nReturn int
set @nReturn = 0

set @sNotifyKey = ''
set @nNotifyType = 0
set @sNotifyData = ''

begin tran

-- gain access to the NotifyQMutex
--exec @nReturn = sp_getapplock @Resource = 'NotifyQMutex', @LockMode = 'Update'

-- select the oldest notification on the notifyQ
select top 1 @sNotifyKey = NotifyKey, @nNotifyType = NotifyType, @sNotifyData = NotifyData from NotifyQ with (nolock) order by NotifyKey asc

-- if there was one present, then remove it from the notifyQ
if @@rowcount <> 0
begin
	delete from NotifyQ with (rowlock) where NotifyKey = @sNotifyKey
	if (@@error = 0)
	begin
		set @nReturn = 1
	end
	else
	begin
		set @nReturn = 0
	end
end

if (@nReturn = 1)
	commit tran
else
	rollback tran

-- release the NotifyQMutex
--exec sp_releaseapplock @Resource = 'NotifyQMutex'

return @nReturn

GO

