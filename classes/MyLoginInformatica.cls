public class MyLoginInformatica {

    public static HttpResponse makePostCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
      request.setEndpoint('https://dm-us.informaticacloud.com/ma/api/v2/user/login');
        request.setMethod('POST');
     //   request.setHeader('icSessionId','jhsSGDKXzEcexv3XLKBDay');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    //    request.setBody('username', 'santhoshkumar.sampath@siriuscom.com.dev');
    //    request.setBody('password', 'Monday@123');
        
        
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        return response;
    }        
   
    
}