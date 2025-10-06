
----------------------------------------------------------------------
-- AmsSp_NotifyQ_Process_2
--
-- Process any items on the NotifyQ.
--
-- Note-
--	we will process up to a maximum of 'NotifyQProcessMax' from the
--	SystemDefaults table.  If entry is not found then set at 10.
--
-- Inputs -
--	@nThrottleValue int
--		Specifies the max number of items to pop off the notifyQ in
--		one session.
--		Defaults to 25
--
-- Outputs -
--	nALUpdated - AL list has been updated
--  nDMLUpdated - DML has been updated
--
-- Returns -
--	none.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_NotifyQ_Process_2
@nThrottleValue int = 25,
@nALUpdated int output,
@nDMLUpdated int output,
@nPSAMUpdated int output
as
declare @nReturn int
set @nReturn = 0
set @nALUpdated = 0
set @nDMLUpdated = 0
set @nPSAMUpdated = 0

-- process while items are on the NotifyQ.
declare @sNotifyKey nvarchar(50)
declare @nNotifyType int
declare @sNotifyData nvarchar(max)
declare @nPopStatus int
declare @nProcessStatus int
declare @nProcessCt int
declare @nALUpdatedTemp int
declare @nDMLUpdatedTemp int
declare @nPSAMUpdatedTemp int
set @nProcessCt = 0
set @nALUpdatedTemp = 0
set @nDMLUpdatedTemp = 0
set @nPSAMUpdatedTemp = 0

exec @nPopStatus = AmsSp_NotifyQ_Pop_1 @sNotifyKey output, @nNotifyType output, @sNotifyData output
while (@nPopStatus <> 0)
begin
	-- process current NotifyQ item.
--print 'Process NotifyQ item key- ' + @sNotifyKey + ', type- ' + cast(@nNotifyType as nvarchar) + ', data- ' + @sNotifyData
	set @nProcessStatus = 0
	exec @nProcessStatus = AmsSp_AL_ProcessNotification_1 @nNotifyType, @sNotifyData, @nALUpdatedTemp output, @nDMLUpdatedTemp output, @nPSAMUpdatedTemp output
	if (@nProcessStatus <> 0)
	begin
		set @nProcessStatus = @nProcessStatus -- need something between begin / end
		-- need to provide someone of this problem.
		-- but we also need to continue processing the NotifyQ
		print 'AmsSp_AL_ProcessNotification_1 returned = ' + cast(@nProcessStatus as nvarchar(10)) + ' for type = ' + cast(@nNotifyType as nvarchar(10))
	end

	if (@nALUpdated <> 1)
	begin
		set @nALUpdated = @nALUpdatedTemp
	end
	if (@nDMLUpdated <> 1)
	begin
		set @nDMLUpdated = @nDMLUpdatedTemp
	end
	if (@nPSAMUpdated <> 1)
	begin
		set @nPSAMUpdated = @nPSAMUpdatedTemp
	end

	-- check to see if we have reached max for this go around.
	set @nProcessCt = @nProcessCt + 1
	if (@nProcessCt >= @nThrottleValue)
	begin
		break -- we have reached the 'throttle'
	end

	-- go get the next NotifyQ item if there is one.
	exec @nPopStatus = AmsSp_NotifyQ_Pop_1 @sNotifyKey output, @nNotifyType output, @sNotifyData output
end

return @nReturn

GO

