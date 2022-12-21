SET NOCOUNT ON;

DECLARE @Conversation uniqueidentifier;

WHILE EXISTS(SELECT 1 FROM sys.conversation_endpoints) -- здесь можно другую очередь подставить вместо системной sys.transmission_queue
BEGIN
  SET @Conversation = 
                (SELECT TOP(1) conversation_handle 
                                FROM sys.conversation_endpoints);
  END CONVERSATION @Conversation WITH CLEANUP;
END;

--sys.conversation_endpoints
--sys.transmission_queue

--END CONVERSATION 'AE1C5E3F-1081-ED11-AFF5-AC220B4F5705' WITH CLEANUP;