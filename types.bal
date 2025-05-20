type Person record {|
    string name;
    string company;
    string designation?;
|};

type LinkContent record {|
    string markdown;
    json stats;
|};

type ScraperResponse LinkContent[];

// Modified to handle json attributes
type OrganicResult record {
    string title;
    string link;
    string snippet;
    int position;
    // Additional optional fields that might come in the response
    string? date?;
    string? sitelinks?;
    json? attributes?;  // Changed from string? to json? to handle complex attributes
    string? imageUrl?;
};