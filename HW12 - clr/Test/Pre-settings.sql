-------------------------------------------------------------------------
USE WideWorldImporters;

-- Предварительные настройки --------------------------------------------
-- если SID владельца базы данных, записанный в базе данных master, 
-- отличается от SID владельца базы данных, записанного в базе данных ''. 
-- Вы должны исправить эту ситуацию, сбросив владельца базы данных '' с помощью инструкции ALTER AUTHORIZATION.
-- нужно выполнить следующий код

--DECLARE @Command VARCHAR(MAX) = 'ALTER AUTHORIZATION ON DATABASE::[WideWorldImporters] TO [sa]' 
--SELECT @Command = REPLACE(REPLACE(@Command 
--            , 'WideWorldImporters', SD.Name)
--            , 'sa', SL.Name)
--FROM master..sysdatabases SD 
--JOIN master..syslogins SL ON  SD.SID = SL.SID
--WHERE  SD.Name = DB_NAME()
--PRINT @Command
--EXEC(@Command)
-------------------------------------------------------------------------
-- Включаем CLR ---------------------------------------------------------
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'clr enabled', 1;
EXEC sp_configure 'clr strict security', 1;
GO
-- clr strict security 
-- 1 (Enabled): заставляет Database Engine игнорировать сведения PERMISSION_SET о сборках 
-- и всегда интерпретировать их как UNSAFE. По умолчанию, начиная с SQL Server 2017.
RECONFIGURE;
GO

-- Для возможности создания сборок с EXTERNAL_ACCESS или UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 

-- Подключаем dll 
DROP ASSEMBLY IF EXISTS SimpleExportExcel;
GO
-- Измените путь к файлу!
CREATE ASSEMBLY SimpleExportExcel
FROM 'C:\Users\nik62\source\repos\ExcelExport\bin\Release\ExcelExport.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS; 
----------------------------------------------------------------------------