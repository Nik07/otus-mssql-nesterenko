-------------------------------------------------------------------------
USE WideWorldImporters;

-- ��������������� ��������� --------------------------------------------
-- ���� SID ��������� ���� ������, ���������� � ���� ������ master, 
-- ���������� �� SID ��������� ���� ������, ����������� � ���� ������ ''. 
-- �� ������ ��������� ��� ��������, ������� ��������� ���� ������ '' � ������� ���������� ALTER AUTHORIZATION.
-- ����� ��������� ��������� ���

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
-- �������� CLR ---------------------------------------------------------
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'clr enabled', 1;
EXEC sp_configure 'clr strict security', 1;
GO
-- clr strict security 
-- 1 (Enabled): ���������� Database Engine ������������ �������� PERMISSION_SET � ������� 
-- � ������ ���������������� �� ��� UNSAFE. �� ���������, ������� � SQL Server 2017.
RECONFIGURE;
GO

-- ��� ����������� �������� ������ � EXTERNAL_ACCESS ��� UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 

-- ���������� dll 
DROP ASSEMBLY IF EXISTS SimpleExportExcel;
GO
-- �������� ���� � �����!
CREATE ASSEMBLY SimpleExportExcel
FROM 'C:\Users\nik62\source\repos\ExcelExport\bin\Release\ExcelExport.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS; 
----------------------------------------------------------------------------