CREATE TABLE [dbo].[StationProperty] (
    [StationPropertyKey]         INT            IDENTITY (1000, 1) NOT NULL,
    [PlantServerKey]             INT            NOT NULL,
    [StationInfoPropertySection] NVARCHAR (256) NOT NULL,
    [StationInfoPropertyKey]     NVARCHAR (256) NOT NULL,
    [StationInfoPropertyValue]   NVARCHAR (256) NOT NULL,
    CONSTRAINT [PK_StationProperty] PRIMARY KEY CLUSTERED ([StationPropertyKey] ASC),
    CONSTRAINT [FK1_PlantServerKey_StationProperty] FOREIGN KEY ([PlantServerKey]) REFERENCES [dbo].[PlantServer] ([PlantServerKey]),
    CONSTRAINT [UC1_StationProperty] UNIQUE NONCLUSTERED ([PlantServerKey] ASC, [StationInfoPropertySection] ASC, [StationInfoPropertyKey] ASC)
);


GO

