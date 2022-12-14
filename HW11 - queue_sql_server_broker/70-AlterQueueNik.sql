/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2017 (14.0.2014)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/
USE [WideWorldImporters]
GO
/****** Object:  ServiceQueue [InitiatorQueueWWI]    Script Date: 6/5/2019 11:57:47 PM ******/
ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
    , ACTIVATION (   STATUS = OFF ,-- ON на автомате обрабатываются быстро
        PROCEDURE_NAME = Sales.ConfirmCustomer, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = OFF , -- ON на автомате обрабатываются быстро
        PROCEDURE_NAME = Sales.GetNewCustomer, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO


-- если обработчиков 0 (MAX_QUEUE_READERS = 0), то при ON , ио будет висеть, пока руками не выполним (как будто OFF)
-- в процедуре обработки 0 параметров