CREATE TABLE [dbo].[NetworkInfo] (
    [NetworkInfoKey]      INT             NOT NULL,
    [PlantServerKey]      INT             NOT NULL,
    [NetworkId]           NVARCHAR (255)  NOT NULL,
    [NetworkName]         NVARCHAR (1024) NOT NULL,
    [NetworkKindAsString] NVARCHAR (1024) NOT NULL,
    CONSTRAINT [PK_NetworkInfo] PRIMARY KEY CLUSTERED ([NetworkInfoKey] ASC),
    CONSTRAINT [FK_NetworkInfo_PlantServer] FOREIGN KEY ([PlantServerKey]) REFERENCES [dbo].[PlantServer] ([PlantServerKey])
);


GO

