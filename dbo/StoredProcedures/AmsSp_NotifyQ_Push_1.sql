----------------------------------------------------------------------
-- AmsSp_NotifyQ_Push_1
--
-- Add a notification to the notifyQ table.
--
-- Inputs -
--	NotifyType int - the type of notification.
--  NotifyData nvarchar(1024) - the notification data.
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- Joe Fisher 9/20/2004
-- Joe Fisher 10/25/2004
--
CREATE PROCEDURE AmsSp_NotifyQ_Push_1
@nNotifyType int,
@sNotifyData nvarchar(max)
AS

set nocount on

declare @nReturn int
set @nReturn = 0

--print 'AmsSp_NotifyQ_Push_1:: NotifyType- ' + cast(@nNotifyType as nvarchar(10))

/*
 * for when there was a notifyQ table
*/
declare @sNotifyKey nvarchar(50)
set @sNotifyKey = ''

-- gain access to the NotifyQMutex
--exec @nReturn = sp_getapplock @Resource = 'NotifyQMutex', @LockMode = 'Update'

-- generate a notifyQId.
exec @nReturn = AmsSp_NotifyQ_GenerateKey_1 @sNotifyKey OUTPUT
if (@nReturn <> 0) 
begin
--	exec sp_releaseapplock @Resource = 'NotifyQMutex'
	return -1
end

-- insert (i.e. push) the notification)
insert into NotifyQ with (rowlock) (NotifyKey, NotifyType, NotifyData) values (@sNotifyKey, @nNotifyType, @sNotifyData)

-- release the NotifyQMutex
--exec sp_releaseapplock @Resource = 'NotifyQMutex'

/*
 *
 */

-- this next statement 'short-circuits' the notifyQ push-pop scheme and calls directly to those
-- processes (i.e. stored-procedures at this time) that need to be kicked by the notification.
--exec @nReturn = AmsSp_AAL_ProcessNotification_1 @nNotifyType, @sNotifyData

return @nReturn

GO

