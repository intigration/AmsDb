-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetSoftwareRev_1
--
-- Get the software revision for the devBlkKey.
--
--
-- Inputs -
--	@nDeviceLevelBlockKey	int
--
-- Outputs -
--	@sSoftwareRevision	nvarchar(10)
--		Will be blank if not found.
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, general error.
--
-- Joe Fisher - 10/21/2003
--

CREATE PROCEDURE AmsSp_DevBlk_GetSoftwareRev_1
@nDeviceLevelBlockKey	int,
@sSoftwareRevision	nvarchar(10) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sSoftwareRevision = ''

declare @paramData varchar(max)
set @paramData = null

-- note: this works only for HART device types.
select top 1 @paramData = blockData.paramData from blockData with (nolock)
where (blockData.blockKey = @nDeviceLevelBlockKey) and
	  (blockData.paramName = 'software_revision.0000009E.0000.0000')

if (@paramData is null)
begin
	print '@paramData not found for devBlockKey- ' + cast(@nDeviceLevelBlockKey as nvarchar(10))
	set @sSoftwareRevision = ''
end
else
begin
	declare @nSoftwareRevision int
	-- we need to reconstruct the parameter data.
	set @nSoftwareRevision = cast(cast(left(@paramData,1) as binary(1)) as int)
	set @nSoftwareRevision = @nSoftwareRevision + (cast(cast(substring(@paramData,2,1) as binary(1)) as int) * 256)
	set @nSoftwareRevision = @nSoftwareRevision + (cast(cast(substring(@paramData,3,1) as binary(1)) as int) * 65536)
	set @nSoftwareRevision = @nSoftwareRevision + (cast(cast(substring(@paramData,4,1) as binary(1)) as int) * 16777216)
	set @sSoftwareRevision = cast(@nSoftwareRevision as nvarchar(20))
	print 'software revision found = ' + @sSoftwareRevision
end

return @iReturnVal

GO

