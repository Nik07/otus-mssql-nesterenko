
-------------------------------------------------------------------------
USE WideWorldImporters;
----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS [dbo].[prc_ExportToExcel];
GO

CREATE PROCEDURE [dbo].[prc_ExportToExcel]
       @proc [nvarchar](100),
       @path [nvarchar](200),
       @filename [nvarchar](100),
       @params xml
AS
EXTERNAL NAME [SimpleExportExcel].[StoredProcedures].[ExportToExcel];

 

DROP PROCEDURE IF EXISTS dbo.ExcelDemo;
GO

CREATE PROCEDURE ExcelDemo
AS
BEGIN
    SELECT 'sysobjects', * FROM sys.objects
    SELECT 'syscolumns', * FROM sys.columns
END

-- Используем ХП
DECLARE @params XML
SET @params='<params></params>'
EXEC dbo.prc_ExportToExcel 'dbo.ExcelDemo', 'C:\1\', 'ExcelDemo', @params

-- в результате выполнения получим файл с расширением xls  с двумя листами,
-- который можно открыть excel-ом (проигнорировав предупреждение)

