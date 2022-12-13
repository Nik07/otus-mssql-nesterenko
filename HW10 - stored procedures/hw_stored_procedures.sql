/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

-- =============================================
CREATE OR ALTER FUNCTION CustomerWithMaxPurchase()
RETURNS INT
AS
BEGIN
    DECLARE @CustomerID int
    SELECT @CustomerID = [Invoices].CustomerID
    FROM
        (
        SELECT TOP(1) InvoiceID, SUM(Quantity * UnitPrice) AS Total
        FROM [Sales].[InvoiceLines] WITH (NOLOCK)
        GROUP BY InvoiceID
        ORDER BY Total DESC
        ) AS Lines
        JOIN [Sales].[Invoices] WITH (NOLOCK) ON [Invoices].InvoiceID = Lines.InvoiceID
    RETURN @CustomerID
END
GO

--- использование -------------------------------------------------------
SELECT dbo.CustomerWithMaxPurchase()
-------------------------------------------------------------------------

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE OR ALTER PROCEDURE CustomerTotalPurchase 
    @CustomerID INT,
    @total DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @total = (SELECT SUM(Quantity * UnitPrice)
    FROM 
        [Sales].[Invoices]
        JOIN [Sales].[InvoiceLines] WITH (NOLOCK) 
            ON [InvoiceLines].InvoiceID = [Invoices].InvoiceID
    WHERE [Invoices].CustomerID = @CustomerID)
END
GO

--- использование -------------------------------------------------------
DECLARE @tot DECIMAL(18,2);
EXEC dbo.CustomerTotalPurchase @CustomerID = 6, @total = @tot OUT
SELECT @tot
-------------------------------------------------------------------------

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
--===============================================================
-- функция аналогичная процедуре CustomerTotalPurchase выше для сравнения
CREATE OR ALTER FUNCTION CustomerTotalPurchaseFun 
(	
    @CustomerID INT
)
RETURNS DECIMAL(18,2) 
--	WITH SCHEMABINDING 
BEGIN
    RETURN (SELECT SUM(Quantity * UnitPrice)
            FROM 
                [Sales].[Invoices]
                JOIN [Sales].[InvoiceLines] WITH (NOLOCK) 
                    ON [InvoiceLines].InvoiceID = [Invoices].InvoiceID
            WHERE [Invoices].CustomerID = @CustomerID)
END
GO

--- использование -------------------------------------------------------
SET STATISTICS TIME ON
DECLARE @tot DECIMAL(18,2);
EXEC dbo.CustomerTotalPurchase @CustomerID = 6, @total = @tot OUT

SELECT dbo.CustomerTotalPurchaseFun(6)

-- процедура CPU time = 0 ms,  elapsed time = 8 ms.
-- функция   CPU time = 0 ms,  elapsed time = 6 ms.

-- получилось, что функция быстрее работает
-- в общем случае зависит от использования функции и процедуры
-- функция имеет больше ограничений, но для простых вычислений, по-видимому будет быстрее (ближе к телу базы данных)

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

-- =============================================
CREATE OR ALTER FUNCTION CustomerSum 
(	
    @CustomerID INT
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT 
        [Total] = SUM(Quantity * UnitPrice) 
    FROM 
        [Sales].[Invoices]
        JOIN [Sales].[InvoiceLines] WITH (NOLOCK) 
            ON [InvoiceLines].InvoiceID = [Invoices].InvoiceID
    WHERE [Invoices].CustomerID = @CustomerID
)
GO

SELECT 
    Customers.CustomerName,
    CustomerSum.Total
FROM 
    Sales.Customers
    CROSS APPLY dbo.CustomerSum([Customers].CustomerID) AS CustomerSum

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/

-- здесь только чтение, в принципе запрос должен быстро выполняться достаточно Read Committed

-- однако в ряде запросах использовал WITH (NOLOCK) для практики
-- предложил бы уровень изоляции Read Uncommitted, если бы запросы были более сложные и выполнялись долго