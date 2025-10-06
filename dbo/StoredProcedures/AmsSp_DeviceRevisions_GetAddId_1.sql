-----------------------------------------------------------------------
-- AmsSp_DeviceRevisions_GetAddId_1
--
-- Get Device Revision Id. if not found, then add it.
--
-- Inputs -
--	@nDeviceTypeId int
--		Device Type Id
--	@sDeviceRevisionCode nvarchar(255)
--		Device Revision code
--	@sDevCategoryId int
--		Device Category ID
--	@sName	nvarchar(255)
--		Device Type Name
--	@sDescription	nvarchar(255)
--		Device Type description
--
-- Outputs -
--	nDeviceRevId
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get mfr id.
--
-- Jane Xiao (6/23/2003)
--

CREATE PROCEDURE AmsSp_DeviceRevisions_GetAddId_1
@nDeviceTypeId int,
@sDeviceRevisionCode nvarchar(255),
@sDevCategoryId int,
@sName nvarchar(255),
@sDescription nvarchar(255),
@nDeviceRevId int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get DeviceRevId if present.
select @nDeviceRevId = AmsDevRevId
from DeviceRevisions with (nolock)
where AmsDevTypeId = @nDeviceTypeId
and (DeviceRevision = @sDeviceRevisionCode or 
     Name = @sName)

if @@rowcount = 0 
--DevRev not found, add it
begin
	-- get the next DevRevId
	declare @NextDevRevId int
	select @NextDevRevId = max(AmsDevRevId) + 1 from DeviceRevisions
	-- add Device Revision to db
	insert DeviceRevisions with (rowlock) (AmsDevRevId, AmsDevTypeId,DeviceRevision,DeviceCategoryId, Name, Description)
	values (@NextDevRevId, @nDeviceTypeId, @sDeviceRevisionCode,@sDevCategoryId, @sName, @sDescription)
	if (@@ERROR <> 0)
	begin
		set @iReturnVal = -1
	end
	else --get new ID
	begin
		set @nDeviceRevId = @NextDevRevId
	end
end

return @iReturnVal

GO

