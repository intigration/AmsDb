-----------------------------------------------------------------------
-- AmsSp_Devices_GetAddKey_1
--
-- Get Devices. if not found, then add it.
--
-- Inputs -
--	@nDevRevId int
--		Device Revision Id
--	@sAmsDeviceId nvarchar(255)
--		Ams Device Id
--	@sIdentifier nvarchar(255)
--		Device ID
--	@sProtocolRev nvarchar(50)
--		Device Protocol Revision
--	@nDisposotionId	smallint
--		Device Disposotion Id
--	@AmsDevTag nvarchar(255)
--		Device Tag Name
--
-- Outputs -
--	nDeviceKey
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get DeviceKey.
--
-- Jane Xiao (6/23/2003)
--

CREATE PROCEDURE AmsSp_Devices_GetAddKey_1
@nDevRevId int,
@sAmsDeviceId nvarchar(255),
@sIdentifier nvarchar(255),
@sProtocolRev nvarchar(50),
@nDisposotionId	smallint,
@AmsDevTag nvarchar(255),
@nDeviceKey int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get DeviceRevId if present.
select @nDeviceKey = DeviceKey
from Devices with (nolock)
where AmsDevRevId = @nDevRevId
and Identifier = @sIdentifier

if @@rowcount = 0 
--Devices not found, add it
begin
	-- get the next DeviceKey
	declare @NextDeviceKey int
	select @NextDeviceKey = max(DeviceKey) + 1 from Devices
	-- add Device to db
	insert Devices with (rowlock) (DeviceKey, AmsDevRevId,AmsDeviceId,Identifier, ProtocolRevision,DispositionId, AmsDeviceTag)
	values (@NextDeviceKey, @nDevRevId, @sAmsDeviceId,@sIdentifier, @sProtocolRev, @nDisposotionId, @AmsDevTag)
	if (@@ERROR <> 0)
	begin
		set @iReturnVal = -1
	end
	else 
	begin
		-- then update CalStatus table
		insert CalStatus with (rowlock) (DeviceKey, 
				  DevLastCalibrationDay,
				  DevLastCalibrationFraction,
				  DevNextCalibrationDueDay, 
				  DevNextCalibrationDueFraction,
				  DevPassedLastCalibration)
		values (@NextDeviceKey, 0, 0,0, 0, '')
		if @@error <> 0 
		    begin
			set @iReturnVal = -1
		    end
		else
		    begin
			set @nDeviceKey = @NextDeviceKey
		    end
	end
end

return @iReturnVal

GO

