public without sharing class Chat {
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled(cacheable=true)
    public static List<ContactChannel__c> getAvailableChannels(Id recordId) {
        return [
            SELECT Id, Name, ChannelRef__c
            FROM ContactChannel__c
            WHERE RelatedEntityRef__c = :recordId
        ];
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled(cacheable=true)
    public static List<Conversation__c> getConversations(
        Id recordId,
        String channelId
    ) {
        try {
            return [
                SELECT Id, ConversationId__c, ChannelRef__c
                FROM Conversation__c
                WHERE
                    ChannelRef__c IN (
                        SELECT ChannelRef__c
                        FROM ContactChannel__c
                        WHERE RelatedEntityRef__c = :recordId
                    )
                    AND ConversationId__c != NULL
                    AND RelatedEntityRef__c = :recordId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static MessageBird.Result getMessages(String conversationId) {
        if (String.isBlank(conversationId)) {
            return null;
        }

        return MessageBird.getMessagesInConversation(
            new Map<String, Object>{ 'conversationId' => conversationId }
        );
    }

    @AuraEnabled
    public static MessageBird.Result replyConversation(
        Map<String, Object> params
    ) {
        try {
            Map<String, Object> apiParams = new Map<String, Object>{
                'type' => params.get('type'),
                'text' => params.get('content'),
                'conversationId' => params.get('conversationId')
            };
            return MessageBird.replyConversation(apiParams);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
