@SuppressWarnings('PMD.ExcessivePublicCount')
public class MessageBird {
    private static final String START_CONVERSATION = 'startConversation';
    private static final String SEND_MESSAGE = 'sendMessage';
    private static final String GET_MESSAGE = 'getMessage';
    private static final String REPLY_CONVERSATION = 'replyConversation';

    /**
     * Returns the base request object so we never forget to set the
     * authorization header.
     *
     * @return The HttpRequest object with the authorization header.
     */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    private static HttpRequest getBaseRequest() {
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');
        request.setHeader('Authorization', 'AccessKey {!$Credential.Password}');
        request.setHeader('Content-Type', 'application/json');

        return request;
    }

    public static MessageBird.Result getAccountBalance() {
        HttpRequest request = getBaseRequest();
        MessageBird.Result result = new MessageBird.Result();

        request.setEndpoint('callout:MessageBird/balance');

        HttpResponse response = new Http().send(request);

        return handleResponse(response, MessageBird.Balance.class);
    }

    public static MessageBird.Result startConversation(
        Map<String, Object> params
    ) {
        HttpRequest request = getBaseRequest();

        request.setMethod('POST');
        request.setEndpoint('callout:MessageBird/v1/conversations/start');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(getPayloadFor(START_CONVERSATION, params));

        HttpResponse response = new Http().send(request);

        return handleResponse(response, MessageBird.Conversation.class);
    }

    public static MessageBird.Result getConversationMessages(
        Map<String, Object> params
    ) {
        HttpRequest request = getBaseRequest();

        if (!params.containsKey('conversationId')) {
            throw new MessageBirdException('Missing conversation ID.');
        }

        request.setEndpoint(
            'callout:MessageBird/v1/conversations/' +
            params.get('conversationId') +
            '/messages'
        );
        request.setHeader('Accept', 'application/json');

        HttpResponse response = new Http().send(request);

        return handleResponse(response, MessageBird.ConversationMessages.class);
    }

    public static MessageBird.Result replyConversation(
        Map<String, Object> params
    ) {
        HttpRequest request = getBaseRequest();

        request.setMethod('POST');
        request.setEndpoint(
            'callout:MessageBird/v1/conversations/' +
            params.get('conversationId') +
            '/messages'
        );
        request.setHeader('Content-Type', 'application/json');
        request.setBody(getPayloadFor(REPLY_CONVERSATION, params));

        HttpResponse response = new Http().send(request);

        return handleResponse(response, MessageBird.SendMessageResult.class);
    }

    public static MessageBird.Result getMessagesInConversation(
        Map<String, Object> params
    ) {
        HttpRequest request = getBaseRequest();

        request.setEndpoint(
            'callout:MessageBird/v1/conversations/' +
            params.get('conversationId') +
            '/messages'
        );
        request.setHeader('Accept', 'application/json');

        HttpResponse response = new Http().send(request);

        return handleResponse(response, MessageBird.ConversationMessages.class);
    }

    public static MessageBird.Result getMessage(Map<String, Object> params) {
        HttpRequest request = getBaseRequest();

        request.setEndpoint(
            'callout:MessageBird/v1/messages/' + params.get('messageId')
        );
        request.setHeader('Accept', 'application/json');

        HttpResponse response = new Http().send(request);

        return handleResponse(response, MessageBird.SendMessageResult.class);
    }

    private static String getPayloadFor(
        String payloadName,
        Map<String, Object> params
    ) {
        if (payloadName == START_CONVERSATION) {
            return JSON.serialize(
                new Map<String, Object>{
                    'type' => params.get('type'),
                    'content' => new Map<String, Object>{
                        'text' => params.get('content')
                    },
                    'to' => params.get('to'),
                    'channelId' => params.get('channelId')
                }
            );
        }
        if (payloadName == REPLY_CONVERSATION) {
            return JSON.serialize(
                new Map<String, Object>{
                    'type' => params.get('type'),
                    'content' => new Map<String, Object>{
                        'text' => params.get('text')
                    }
                }
            );
        }

        return '{}';
    }

    private static MessageBird.Result handleResponse(
        HttpResponse response,
        Type returningType
    ) {
        System.debug(response.getBody());
        MessageBird.Result result = new MessageBird.Result();

        if (response.getStatusCode() / 100 != 2) {
            try {
                result.hasError = true;
                result.data = (MessageBird.Errors) JSON.deserialize(
                    response.getBody(),
                    MessageBird.Errors.class
                );
                return result;
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                System.debug(LoggingLevel.ERROR, response.getBody());
                throw new MessageBirdException(
                    'Bad callout: ' + response.getStatusCode()
                );
            }
        }

        result.hasError = false;
        result.data = (MessageBird.Response) JSON.deserialize(
            response.getBody()
                .replaceAll('"from"', '"fromx"')
                .replaceAll('"limit"', '"limitx"'),
            returningType
        );

        return result;
    }

    public class ConversationMessages implements MessageBird.Response {
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public List<MessageBird.Message> items;
        @AuraEnabled
        public Integer limitx;
        @AuraEnabled
        public Integer offset;
        @AuraEnabled
        public Integer totalCount;
    }

    public class Message {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String conversationId;
        @AuraEnabled
        public String platform;
        @AuraEnabled
        public String to;
        @AuraEnabled
        public String fromx;
        @AuraEnabled
        public String channelId;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public MessageContent content;
        @AuraEnabled
        public String direction;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Datetime createdDatetime;
        @AuraEnabled
        public Datetime updatedDatetime;
    }

    public class SendMessageResult implements MessageBird.Response {
        public String id;
        public String status;
        public String direction;
        public String platform;
        public String conversationId;
        public MessageBird.Error error;
    }

    public class Conversation implements MessageBird.Response {
        public String id;
        public String contactId;
        public ConversationContact contact;
        public List<ConversationChannel> channels;
        public String status;
        public Datetime createdDatetime;
        public Datetime updatedDatetime;
        public Datetime lastReceivedDatetime;
        public String lastUsedChannelId;
        public String lastUsedPlatformId;
        public ConversationMessagesSummary messages;
    }

    public class ConversationMessagesSummary {
        public Integer totalCount;
        public String href;
        public String lastMessageId;
    }

    public class ConversationChannel {
        public String id;
        public String name;
        public String platformId;
        public String status;
        public Datetime createdDatetime;
        public Datetime updatedDatetime;
    }

    public class ConversationContact {
        public String id;
        public String firstName;
        public String lastName;
        public Datetime createdDatetime;
        public Datetime updatedDatetime;
    }

    public class StartConversation {
        public String to;
        public String channelId;
        public String type;
        public MessageContent content;
    }

    public class MessageContent {
        @AuraEnabled
        public String text;
    }

    public interface Response {
    }

    public class Result {
        @AuraEnabled
        public Boolean hasError;
        @AuraEnabled
        public Response data;
    }

    public class Balance implements MessageBird.Response {
        public String payment;
        public String type;
        public Decimal amount;
    }

    public class Errors implements MessageBird.Response {
        public List<Error> errors;
    }

    public class Error {
        public Integer code;
        public String description;
        public String parameter;
    }

    public class MessageBirdException extends Exception {
    }
}
