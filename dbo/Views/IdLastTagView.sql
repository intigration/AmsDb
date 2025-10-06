
/****** Object:  View dbo.IdLastTagView    Script Date: 1/19/00 2:09:53 PM ******/

--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
Create View IdLastTagView As
SELECT ExtBlockTags.ExtBlockTag, BlockAsgms.BlockKey
FROM ExtBlockTags INNER JOIN
    BlockAsgms ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey
WHERE (BlockAsgms.EventIdDayOut = 49710)

GO

