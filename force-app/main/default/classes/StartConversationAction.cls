public without sharing class StartConversationAction {
    @InvocableMethod(
        label='Start Conversation'
        description='Start a conversation with a person.'
        category='Message Bird'
    )
    public static List<Output> methodName(List<Input> inputs) {
        List<Output> result = new List<Output>();

        for (Input input : inputs) {
            result.add(execute(input));
        }

        return result;
    }

    private static Output execute(Input input) {
        Output o = new Output();

        if (input.message == null || input.recordId == null) {
            o.success = false;
        }

        MessageBird.Result re = MessageBird.startConversation(
            new Map<String, Object>{
                'type' => 'text',
                'content' => input.message,
                'to' => input.recipientId,
                'channelId' => input.channelId
            }
        );

        if (!re.hasError) {
            MessageBird.Conversation conversationData = (MessageBird.Conversation) re.data;
            o.conversationId = conversationData.id;
        }

        o.success = !re.hasError;

        return o;
    }

    public class Input {
        @InvocableVariable(
            label='Message content'
            description='Content of the message to send.'
        )
        public String message;
        @InvocableVariable(label='Salesforce Record ID')
        public String recordId;
        @InvocableVariable(
            label='Channel ID'
            description='The unique ID that identifies the channel through which the message should be sent.'
        )
        public String channelId;
        @InvocableVariable(
            label='Recipient Identifier'
            description='The platform-specific identifier of the recipient.'
        )
        public String recipientId;
    }

    public class Output {
        @InvocableVariable(label='Success')
        public Boolean success = true;
        @InvocableVariable(label='Conversation ID')
        public String conversationId;
    }
}
