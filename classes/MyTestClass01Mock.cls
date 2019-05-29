@isTest
global class  MyTestClass01Mock implements HttpCalloutMock{
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
        response.setBody('{"error": {"code": "AUTH_01","message": "Authentication failure. ","requestId": "h1rmc7WZMU4cGgfsxC9R4U"}}');
        response.setStatusCode(200);
        return response; 
    }
}