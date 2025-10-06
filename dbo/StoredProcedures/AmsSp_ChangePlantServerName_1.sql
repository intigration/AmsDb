
-----------------------------------------------------------------------
-- AmsSp_ChangePlantServerName_1
--
-- Purpose: to change all devices currently associated with the PlantServer
--	name of src to dest.
--
--	If destPsName does not currently exist in the database it will be added
--	if there are devices associated to the source PlantServer name.
--
-- Inputs -
--	srcPsName	nvarchar(256)	the plantServer name that the devices are
--					currently assigned to.
--
--	destPsName	nvarchar(256)	the plantServer name that the devices will
--					be assigned to.
--
-- Outputs -
--	None.
--
-- Returns -
--	returns number of DeviceLocation records changed.
--	-1 - Error, unable to perform operation.
--
-- Joe Fisher 12/19/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_ChangePlantServerName_1
@srcPcName as nvarchar(256),
@destPcName as nvarchar(256)
AS
set nocount on
declare @nSrcPlantServerKey integer
declare @nDestPlantServerKey integer
declare @iReturnVal integer
set @iReturnVal = 0

-- get the database key for source plantServer name.
exec @iReturnVal = AmsSp_GetPlantServerKey_1 @srcPcName, @nSrcPlantServerKey output
if (@iReturnVal <> 0)
begin
	-- failed to get the plantServer info for source.
	-- We do not have any devices associated to this. We do not need to go
	-- any further.
	return -2
end

-- go get the database key for the source PsName.  If not found go ahead and add it.
exec @iReturnVal = AmsSp_GetAdd_PlantServer_1 @destPcName, @nDestPlantServerKey output
if (@iReturnVal <> 0)
begin
	-- failed to get/add the destination plantServer info.
	return -1
end


-- so far we have verified that the destination plantServer info is in the database and
-- we also have source plantServer in the database.
-- Now for all devices that are associated to the source plantServer change them to be
-- associated to the destination plantServer.
update DeviceLocation set PlantServerKey = @nDestPlantServerKey where PlantServerKey = @nSrcPlantServerKey

return (@@ROWCOUNT)

GO

