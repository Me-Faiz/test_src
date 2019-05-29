global class WFLoginMockResp implements HttpCalloutMock {
    global enum TYPE {SUCCESS,AUTH_ERROR}  
    private TYPE cLoginType;
    global WFLoginMockResp(TYPE cLoginType)
    {
        this.cLoginType=cLoginType;
    }
    global HttpResponse respond(HttpRequest req) {
        
        System.debug('WFLoginMockResp called with type '+cLoginType);
        String resBody = '';
        
        Integer statusCode=200;
         if(cLoginType.equals(TYPE.SUCCESS))
        {
          resBody='{"id": "001S8M0300000000000I","orgId": "001S8M","orgUuid": "jyVzrTFO2QalUIsD5tW6Ao","name": "santhoshkumar.sampath@siriuscom.com.dev","description": "","createTime": "2018-11-20T00:35:48.000Z","updateTime": "2018-12-28T11:03:04.000Z","createdBy": "OrgMigUser_1542674026095","updatedBy": "santhoshkumar.sampath@siriuscom.com.dev","sfUsername": null,"firstName": "santhoshkumar","lastName": "sampath","title": "Consultant Trainee","password": "********","phone": "+91 44 6650 7800","emails": "santhoshkumar.sampath@siriuscom.com","timezone": null,"serverUrl": "https://use4.dm-us.informaticacloud.com/saas","icSessionId": "0llFSkCy5DXhKEn4OXsZQD","securityQuestion": "In what city were you born?","securityAnswer": "********","uuid": "amQAPTdkmTkhJ0xbf5NNgy","forceChangePassword": false,"roles": [{"name": "Admin","description": "Role for performing administrative tasks for an organization. Has full access to all licensed services."},{"name": "Data Preview","description": "Role to preview data"},{"name": "Migrated CAI Designer","description": "For migrated designer users"},{"name": "Service Consumer","description": "Role for running tasks, taskflows, and processes."}],"usergroups": [{"id": "0uRT0E3FSMsb7RhH0vHx45","orgId": "001S8M","name": "WSGroup","createTime": "2018-11-20T00:35:40.000Z","updateTime": "2018-11-20T00:43:17.000Z","createdBy": "OrgMigUser_1542674026095","updatedBy": "OrgMigUser_1542674026095"}],"spiUrl": null}';
        } else  if(cLoginType.equals(TYPE.AUTH_ERROR))
        {
           resBody='{"code": "UI_10000","description": "User name or password is not valid.","statusCode": 403,"@type": "error"}';
           statusCode = 403;
        }
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(resBody);
        res.setStatusCode(statusCode);
        return res;
    }
}