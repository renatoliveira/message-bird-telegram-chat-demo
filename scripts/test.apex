Map<String, Object> params = new Map<String, Object>{
  'type' => 'text',
  'content' => 'Hello, world!',
  'to' => '171201065',
  'channelId' => '88bb61ee5c0a43059d91354e4af54525'
};

MessageBird.Result re = MessageBird.startConversation(params);
System.debug(re);
// System.debug(MessageBird.sendMessage(params));
// System.debug(MessageBird.getMessagesInConversation(new Map<String, Object>{'conversationId' => 'becc0c6877b0403dba4d76db26937d1b'}));
MessageBird.Conversation conversation = (MessageBird.Conversation) re.data;
// System.debug(MessageBird.getMessage(new Map<String, Object>{'messageId' => conversation.messages.lastMessageId}));
System.debug(
  MessageBird.getMessage(
    new Map<String, Object>{ 'messageId' => '90f0d48dd2fa492d9c9d06882bc0bd4f' }
  )
);
