
-----------------------------------------------------------------------
-- AmsSp_GetAmsTags_2
--
-- Get list of AmsTags with the following information (see output section.)
-- Obtain both tags assigned to devices and tags that are used as template names.
-- Include information pertaining whether the tag is currently assigned (1)
-- or not (0).
--
-- Inputs -
--	none.
--
-- Outputs -
--	Recordset with the following --
--		AmsTag
--		TagType	-- either 'placeholder' or 'template'
--		CurrentlyAssigned -- either 1 or 0, currently assigned or not.
--
-- Returns -
--	returns number of records in recordset.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 11/21/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE  PROCEDURE AmsSp_GetAmsTags_2
AS

declare @iReturnVal int
set @iReturnVal = 0

SELECT     ExtBlockTag as AmsTag,
		'placeholder' as TagType,
		case max(dbo.BlockAsgms.EventIdDayOut)
			when 49710 then 1
			else 0
		end as CurrentlyAssigned
FROM         dbo.ExtBlockTags LEFT OUTER JOIN
                      dbo.BlockAsgms ON dbo.ExtBlockTags.ExtBlockTagKey = dbo.BlockAsgms.ExtBlockTagKey
group by extblocktag
union
select ConfigName as AmsTag, 'template' as TagType, 1 as CurrentlyAssigned from NamedConfigs

declare @Err int, @nRow int
select @Err = @@ERROR, @nRow = @@ROWCOUNT

if (@Err <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = @nRow

return @iReturnVal

GO

