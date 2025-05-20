import test_geronimo.Serper;

import ballerina/http;
import ballerinax/openai.chat;

final Serper:Client serperClient = check new ({
    x\-api\-key: serperKey
});

final http:Client scraperClient = check new (scraperUrl);

final chat:Client chatClient = check new ({
    auth: {
        token: openaiKey
    }
});