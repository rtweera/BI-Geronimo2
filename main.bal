import ballerina/http;
import ballerina/lang.array;
import ballerinax/openai.chat;

import Ravindu/test_geronimo.Serper;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service / on httpDefaultListener {

    resource function post person/search(@http:Payload Person payload) returns error|json {
        do {
            string searchQuery = payload.name + " " + payload.company;
            string|() designation = payload.designation;
            if designation !is () {
                searchQuery = searchQuery + " " + designation;
            }
            Serper:inline_response_200 searchResponse = check serperClient->/search.post({
                q: searchQuery
            });
            string[] links = [];

            // Type cast and handle the organic content
            if searchResponse?.organic is json[] {
                json[] organicContent = <json[]>searchResponse?.organic;
                foreach json item in organicContent {
                    // Using cloneWithType with explicit type parameter
                    OrganicResult result = check item.cloneWithType(OrganicResult);
                    links.push(result.link);
                }
            }
            ScraperResponse scraperResult = check scraperClient->post("", {
                "links": links
            });
            string[] markdownContent = [];
            foreach LinkContent content in scraperResult {
                array:push(markdownContent, content.markdown);
            }
            string systemPrompt = "You are an expert assistant in profiling people based on given context. Using the given context in the user prompt, make a summary about the person in a point form. Aim for 10 points or more. Dont' create unnecessary points. Person's name is " + payload.name + " and person's place of work is " + payload.company;
            string userPrompt = "Based on this content, provide the person summary\n\n" + markdownContent.toString();
            chat:CreateChatCompletionResponse chatResponse = check chatClient->/chat/completions.post({
                messages: [
                    {
                        "role": "system",
                        "content": systemPrompt
                    },
                    {
                        "role": "user",
                        "content": userPrompt
                    }
                ],
                model: "gpt-4o"
            });

            return chatResponse.choices[0].message.content.toJson();

        } on fail error err {
            return error("Failed to get personal information", err);
        }
    }
}
