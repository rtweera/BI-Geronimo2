# BI-Geronimo2

A Ballerina-based web service for intelligent person profiling that combines web search, content scraping, and AI analysis to generate comprehensive profiles of individuals.

## Overview

BI-Geronimo2 is a REST API service that creates detailed profiles of people by:
1. Searching the web using Serper API (Google Search)
2. Scraping content from the retrieved links
3. Processing the content with OpenAI's GPT-4 to generate a professional summary

This tool is useful for recruitment, due diligence, competitive intelligence, and professional research.

## Features

- **Web Search Integration**: Uses Serper API to find relevant information about a person
- **Content Scraping**: Automatically scrapes web pages to extract meaningful content
- **AI-Powered Analysis**: Leverages OpenAI's GPT-4 to generate intelligent summaries
- **REST API**: Simple HTTP endpoint for easy integration
- **Flexible Search**: Supports searching by name, company, and optional designation

## Architecture

```
┌─────────────────┐
│   REST Client   │
└────────┬────────┘
         │
    POST /person/search
         │
         ▼
┌──────────────────────┐
│  Ballerina Service   │
└──────────┬───────────┘
           │
     ┌─────┴──────┬──────────┬─────────────┐
     │            │          │             │
     ▼            ▼          ▼             ▼
┌────────┐  ┌────────┐  ┌────────┐  ┌──────────┐
│ Serper │  │ Scraper│  │ OpenAI │  │ Ballerina│
│  API   │  │ Client │  │  Chat  │  │ HTTP Lib │
└────────┘  └────────┘  └────────┘  └──────────┘
```

## Project Structure

```
├── main.bal              # Main HTTP service and person search endpoint
├── types.bal             # Data type definitions (Person, LinkContent, etc.)
├── config.bal            # Configuration variables (API keys, URLs)
├── connections.bal       # External service client initialization
├── agents.bal            # Agent configurations (if used)
├── functions.bal         # Utility functions
├── data_mappings.bal     # Data mapping configurations
├── Ballerina.toml        # Ballerina package configuration
├── Dependencies.toml     # Project dependencies
└── README.md             # This file
```

## Prerequisites

- **Ballerina** (version 2.0 or later)
- **Serper API Key** (from https://serper.dev)
- **OpenAI API Key** (from https://openai.com)
- **Web Scraper Service** (accessible via HTTP)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/rtweera/BI-Geronimo2.git
cd BI-Geronimo2
```

### 2. Install Ballerina

Download and install Ballerina from [ballerina.io](https://ballerina.io/downloads/)

### 3. Install Dependencies

```bash
bal build
```

This will download all required dependencies specified in `Dependencies.toml`

## Configuration

Set the following environment variables or use Ballerina configuration files:

### Environment Variables

```bash
# OpenAI API Key
export OPENAI_KEY="sk-..."

# Serper API Key
export SERPER_KEY="..."

# Web Scraper Service URL
export SCRAPER_URL="http://localhost:8000"
```

### Configuration File

You can also configure these in a `Config.toml` file in the project root:

```toml
openaiKey = "sk-..."
serperKey = "..."
scraperUrl = "http://localhost:8000"
```

## Running the Service

### Development Mode

```bash
bal run
```

The service will start on the default HTTP listener port (typically 8080 or 9090).

### Production Mode

```bash
bal build
bal run --offline
```

## API Endpoints

### POST /person/search

Search for and profile a person based on their name, company, and optional designation.

#### Request

```http
POST /person/search
Content-Type: application/json

{
  "name": "John Doe",
  "company": "Tech Corporation",
  "designation": "Software Engineer"
}
```

#### Request Body Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | The person's full name |
| `company` | string | Yes | The person's company or organization |
| `designation` | string | No | The person's job title or designation |

#### Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "choices": [
    {
      "message": {
        "content": "• Software Engineer with 8+ years of experience...\n• Specializes in cloud architecture...\n• Active open source contributor...\n..."
      }
    }
  ]
}
```

#### Response Schema

The API returns a JSON object containing:
- `choices[0].message.content`: A formatted string containing the person's profile summary with bullet points

#### Error Handling

Errors are returned with appropriate HTTP status codes:

```json
{
  "error": "Failed to get personal information",
  "cause": "Details about what went wrong"
}
```

## Usage Examples

### Example 1: Basic Profile Search

```bash
curl -X POST http://localhost:8080/person/search \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Satya Nadella",
    "company": "Microsoft"
  }'
```

### Example 2: Search with Designation

```bash
curl -X POST http://localhost:8080/person/search \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Elon Musk",
    "company": "Tesla",
    "designation": "CEO"
  }'
```

### Example 3: Using cURL with Config File

```bash
curl -X POST http://localhost:8080/person/search \
  -H "Content-Type: application/json" \
  -d @person_request.json
```

Where `person_request.json` contains:
```json
{
  "name": "Jane Smith",
  "company": "Google",
  "designation": "Product Manager"
}
```

## Data Types

### Person Record

Represents a person to be searched for:

```ballerina
type Person record {|
    string name;
    string company;
    string designation?;
|};
```

### LinkContent Record

Represents scraped content from a web link:

```ballerina
type LinkContent record {|
    string markdown;
    json stats;
|};
```

### OrganicResult Record

Represents a search result from Serper API:

```ballerina
type OrganicResult record {
    string title;
    string link;
    string snippet;
    int position;
    string? date?;
    string? sitelinks?;
    json? attributes?;
    string? imageUrl?;
};
```

## External Dependencies

### 1. Serper API

Provides Google Search results integration:
- **Purpose**: Search for information about the person
- **Endpoint**: `/search`
- **Authentication**: API Key in header

### 2. OpenAI Chat API

Provides AI-powered analysis and summary generation:
- **Model**: GPT-4o
- **Purpose**: Generate intelligent professional summaries
- **System Prompt**: Customized for person profiling

### 3. Web Scraper Service

Custom HTTP service for content extraction:
- **Purpose**: Extract markdown content from web links
- **Protocol**: HTTP POST
- **Input**: JSON array of links
- **Output**: Array of LinkContent objects

## Workflow

1. **User Request**: Client sends a POST request with person details (name, company, designation)

2. **Search**: System constructs a search query and calls Serper API
   - Query format: `"{name} {company} {designation}"`

3. **Link Extraction**: Extract relevant links from Serper search results

4. **Content Scraping**: Call the web scraper service to fetch and convert web content to markdown

5. **AI Analysis**: Send the scraped content to OpenAI with:
   - System prompt for professional profiling
   - User prompt containing the markdown content

6. **Response**: Return the AI-generated profile summary to the client

## Performance Considerations

- **Search Results**: Limited to organic search results from Serper
- **Scraping**: Content scraper may have rate limits
- **AI Processing**: GPT-4o has rate limits per API key
- **Caching**: Consider implementing caching for frequently searched profiles

## Troubleshooting

### Service Won't Start

**Error**: Port already in use
```
Solution: Change the listener port in config or restart the machine
```

### API Key Errors

**Error**: "Invalid API key"
```
Solution: Verify API keys are correctly set and active
- Check Serper API at https://serper.dev
- Check OpenAI API at https://platform.openai.com/api-keys
```

### Scraper Service Unavailable

**Error**: Connection refused to scraper
```
Solution: Ensure the scraper service is running at the configured URL
```

### Profile Generation Failed

**Error**: "Failed to get personal information"
```
Solution: Check logs for detailed error information:
- Verify internet connectivity
- Check API quotas and rate limits
- Ensure all required fields are provided
```

## Security Considerations

- **API Keys**: Never commit API keys to version control. Use environment variables or secure config management
- **Input Validation**: The service validates all input before processing
- **HTTPS**: Deploy with HTTPS in production
- **Rate Limiting**: Implement rate limiting in production to prevent abuse

## Development

### Building

```bash
bal build
```

### Testing

```bash
bal test
```

### Formatting

```bash
bal format
```

## Dependencies

### Direct Dependencies

- `ballerina/http` - HTTP server and client functionality
- `ballerina/lang.array` - Array utility functions
- `ballerinax/openai.chat` - OpenAI Chat API integration
- `Ravindu/test_geronimo.Serper` - Serper API client (generated from OpenAPI spec)

See `Dependencies.toml` for version information.

## Future Enhancements

- [ ] Add caching layer for repeated searches
- [ ] Implement retry logic with exponential backoff
- [ ] Add support for multiple AI models
- [ ] Add batch processing for multiple people
- [ ] Add database storage for generated profiles
- [ ] Implement webhook notifications
- [ ] Add filtering and customization options for profiles
- [ ] Multi-language support
- [ ] Profile confidence scoring

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**Ravindu** - Initial work

## Support

For issues, questions, or suggestions, please open an issue on the GitHub repository.

## References

- [Ballerina Documentation](https://ballerina.io/learn/)
- [Serper API Documentation](https://serper.dev/docs)
- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
- [Ballerina HTTP Module](https://lib.ballerina.io/ballerina/http/latest)
