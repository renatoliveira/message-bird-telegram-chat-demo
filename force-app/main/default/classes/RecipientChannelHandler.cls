public inherited sharing class RecipientChannelHandler {
    public void run() {
        Set<Id> channelsIds = new Set<Id>();

        for (ContactChannel__c record : (List<ContactChannel__c>) Trigger.new) {
            channelsIds.add(record.ChannelRef__c);
        }

        Map<Id, ConversationChannel__c> channelsById = new Map<Id, ConversationChannel__c>(
            [
                SELECT Id, Name
                FROM ConversationChannel__c
                WHERE Id IN :channelsIds
            ]
        );

        for (ContactChannel__c record : (List<ContactChannel__c>) Trigger.new) {
            record.Name = channelsById.get(record.ChannelRef__c).Name;
        }
    }
}
