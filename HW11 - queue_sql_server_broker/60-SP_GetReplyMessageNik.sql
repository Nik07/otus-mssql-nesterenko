USE [WideWorldImporters]
GO

-- обработка сообщений инициатором --
CREATE OR ALTER PROCEDURE Sales.ConfirmCustomer  
AS
BEGIN
    --Receiving Reply Message from the Target.	
    DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
        @ReplyReceivedMessage NVARCHAR(1000) 

    BEGIN TRAN; 

        RECEIVE TOP(1)
            @InitiatorReplyDlgHandle = Conversation_Handle
            ,@ReplyReceivedMessage = Message_Body
        FROM dbo.InitiatorQueueWWI; 

        IF @InitiatorReplyDlgHandle IS NOT NULL
            BEGIN
                END CONVERSATION @InitiatorReplyDlgHandle; 
                SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; 
            END
    COMMIT TRAN; 
END
