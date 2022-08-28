trigger RecipientChannel on ContactChannel__c(before insert, before update) {
    new RecipientChannelHandler().run();
}
