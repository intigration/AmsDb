CREATE TABLE [dbo].[PlantServer] (
    [PlantServerKey]      INT            NOT NULL,
    [PlantServerId]       NVARCHAR (255) NOT NULL,
    [AlertMonitorEnabled] BIT            CONSTRAINT [DF_PlantServer_AlertMonitorEnabled] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PlantServer] PRIMARY KEY NONCLUSTERED ([PlantServerKey] ASC)
);


GO

