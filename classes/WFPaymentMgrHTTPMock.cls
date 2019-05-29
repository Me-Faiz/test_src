global class WFPaymentMgrHTTPMock implements HttpCalloutMock{
	/*
    public enum MOCK_TYPE {LOGIN_AND_GET_RECENT_INTEGRATION,LOGIN_AND_RUN_INTEGRATION}

       private MOCK_TYPE cMockType;
    public WFPaymentMgrHTTPMock(MOCK_TYPE type)
    {
        this.cMockType=type;
    }
 
        
 public HttpResponse getValidRecentIntegrationResp(){ 
     String resBody='[{"@type": "activityLogEntry","id": "001S8MC1000000000YUQ","type": "WORKFLOW","objectId": "001S8M0N00000000002I","objectName": "TF_SFtoWellsFargoPaymentManager_Daily_6_30","runId": 39,"startTime": "2019-01-02T05:21:55.000Z","endTime": "2019-01-02T05:21:56.000Z","startTimeUtc": "2019-01-02T10:21:55.000Z","endTimeUtc": "2019-01-02T10:21:56.000Z","state": 1,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 0,"errorMsg": "Linear Taskflow failed to run. Another instance of the Linear Taskflow is currently running.","startedBy": "santhoshkumar.sampath@siriuscom.com.dev","runContextType": "REST_API_V2","entries": [{"@type": "activityLogEntry","id": "49741280","type": "MTT","objectName": "MCT_IntegrationMap_M01_SFtoWellsFargoPaymentManager","runId": 71,"state": 4,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 0,"entries": [{"@type": "activityLogEntry","id": "49741281","type": "MTT","objectName": "","runId": 71,"runtimeEnvironmentId": "001S8M2500000000000R","state": 4,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 0,"startedBy": "santhoshkumar.sampath@siriuscom.com.dev","runContextType": "REST_API_V2","entries": [],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false}],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false},{"@type": "activityLogEntry","id": "49741282","type": "DSS","objectName": "DS_WF_SendFiles","runId": 76,"state": 1,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 7,"entries": [{"@type": "activityLogEntry","id": "49741283","type": "DSS","objectName": "SFTP_PUT.csv","runId": 76,"runtimeEnvironmentId": "001S8M2500000000000R","state": 1,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 0,"startedBy": "santhoshkumar.sampath@siriuscom.com.dev","runContextType": "REST_API_V2","entries": [],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false}],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false}],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false}]';   
     HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(resBody);
        res.setStatusCode(200);
        return res;
}
    public HttpResponse getValidLoginResp()
    {
        String resBody='{"id": "001S8M0300000000000I","orgId": "001S8M","orgUuid": "jyVzrTFO2QalUIsD5tW6Ao","name": "santhoshkumar.sampath@siriuscom.com.dev","description": "","createTime": "2018-11-20T00:35:48.000Z","updateTime": "2018-12-28T11:03:04.000Z","createdBy": "OrgMigUser_1542674026095","updatedBy": "santhoshkumar.sampath@siriuscom.com.dev","sfUsername": null,"firstName": "santhoshkumar","lastName": "sampath","title": "Consultant Trainee","password": "********","phone": "+91 44 6650 7800","emails": "santhoshkumar.sampath@siriuscom.com","timezone": null,"serverUrl": "https://use4.dm-us.informaticacloud.com/saas","icSessionId": "0llFSkCy5DXhKEn4OXsZQD","securityQuestion": "In what city were you born?","securityAnswer": "********","uuid": "amQAPTdkmTkhJ0xbf5NNgy","forceChangePassword": false,"roles": [{"name": "Admin","description": "Role for performing administrative tasks for an organization. Has full access to all licensed services."},{"name": "Data Preview","description": "Role to preview data"},{"name": "Migrated CAI Designer","description": "For migrated designer users"},{"name": "Service Consumer","description": "Role for running tasks, taskflows, and processes."}],"usergroups": [{"id": "0uRT0E3FSMsb7RhH0vHx45","orgId": "001S8M","name": "WSGroup","createTime": "2018-11-20T00:35:40.000Z","updateTime": "2018-11-20T00:43:17.000Z","createdBy": "OrgMigUser_1542674026095","updatedBy": "OrgMigUser_1542674026095"}],"spiUrl": null}';
    	HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(resBody);
        res.setStatusCode(200);
        return res;
    }
*/
   // private static final String LOGIN_URL='https://dm-us.informaticacloud.com/ma/api/v2/user/login';
   // private static final String RECENT_INTEGRATION_URL='https://use4.dm-us.informaticacloud.com/saas/api/v2/activity/activityLog?taskId=001S8M0N00000000002I&rowLimit=20';
   
    Map<String, HttpCalloutMock> requests;

	public WFPaymentMgrHTTPMock(Map<String, HttpCalloutMock> requests) {
		this.requests = requests;
	}
    
    global HttpResponse respond(HttpRequest req) {
       
        HttpResponse resp = null;
		HttpCalloutMock mock = requests.get(req.getEndpoint());
        
        System.debug('available requests '+requests);
        System.debug('current req endpoint '+req.getEndpoint());
        System.debug('mock '+mock);
		if (mock != null) {
			resp= mock.respond(req);
		} 
        
      	/*
        if(cMockType.equals(MOCK_TYPE.LOGIN_AND_GET_RECENT_INTEGRATION))
        {
            if(LOGIN_URL.equals(req.getEndpoint()))
            {
                res=getValidLoginResp();
            }else if(RECENT_INTEGRATION_URL.equals(req.getEndpoint()))
            {
               res=getValidRecentIntegrationResp();
            }
			
        }else if(cMockType.equals(MOCK_TYPE.LOGIN_AND_RUN_INTEGRATION))
        {
           	
        }
       */
        
        return resp;
    }

   

    
    /*
   public class MultiRequestMock implements HttpCalloutMock {
	

	public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse resp=null;
		HttpCalloutMock mock = requests.get(req.getEndpoint());
		if (mock != null) {
			resp= mock.respond(req);
		} else {
    			System.debug('HTTP callout not supported for test methods');
		}
        
        return resp;
	}

}*/
    
}