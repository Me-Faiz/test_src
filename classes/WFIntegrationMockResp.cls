global class WFIntegrationMockResp implements HttpCalloutMock {
    global enum TYPE {GET,RUN,NO_RECENT,ALREADY_RUNNING,GLOBAL_ERROR,INFORMATICA_ERROR}
    private TYPE cType;
    global WFIntegrationMockResp(TYPE cType)
    {
        this.cType=cType;
    }
    global HttpResponse respond(HttpRequest req) {
        System.debug('WFIntegrationMockResp called with type '+cType);
        String resBody='[]';
        Integer statusCode=200; //By default
        if(cType.equals(TYPE.GET))
        {
            resBody='[{"@type": "activityLogEntry","id": "001S8MC1000000000YUQ","type": "WORKFLOW","objectId": "001S8M0N00000000002I","objectName": "TF_SFtoWellsFargoPaymentManager_Daily_6_30","runId": 39,"startTime": "2019-01-02T05:21:55.000Z","endTime": "2019-01-02T05:21:56.000Z","startTimeUtc": "2019-01-02T10:21:55.000Z","endTimeUtc": "2019-01-02T10:21:56.000Z","state": 1,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 0,"errorMsg": "Linear Taskflow failed to run. Another instance of the Linear Taskflow is currently running.","startedBy": "santhoshkumar.sampath@siriuscom.com.dev","runContextType": "REST_API_V2","entries": [{"@type": "activityLogEntry","id": "49741280","type": "MTT","objectName": "MCT_IntegrationMap_M01_SFtoWellsFargoPaymentManager","runId": 71,"state": 4,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 0,"entries": [{"@type": "activityLogEntry","id": "49741281","type": "MTT","objectName": "","runId": 71,"runtimeEnvironmentId": "001S8M2500000000000R","state": 4,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 0,"startedBy": "santhoshkumar.sampath@siriuscom.com.dev","runContextType": "REST_API_V2","entries": [],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false}],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false},{"@type": "activityLogEntry","id": "49741282","type": "DSS","objectName": "DS_WF_SendFiles","runId": 76,"state": 1,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 7,"entries": [{"@type": "activityLogEntry","id": "49741283","type": "DSS","objectName": "SFTP_PUT.csv","runId": 76,"runtimeEnvironmentId": "001S8M2500000000000R","state": 1,"failedSourceRows": 0,"successSourceRows": 0,"failedTargetRows": 0,"successTargetRows": 0,"startedBy": "santhoshkumar.sampath@siriuscom.com.dev","runContextType": "REST_API_V2","entries": [],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false}],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false}],"totalSuccessRows": 0,"totalFailedRows": 0,"stopOnError": false,"hasStopOnErrorRecord": false}]';   
        }else if(cType.equals(TYPE.RUN))
        {
            resBody='{"@type": "job","taskId": "001S8M0N00000000002I","taskType": "WORKFLOW","runId": 40,"taskName": "TF_SFtoWellsFargoPaymentManager_Daily_6_30","runInParallel": false}';
        }else if(cType.equals(TYPE.NO_RECENT))
        {
            resBody='[]';           
        }    
        else if(cType.equals(TYPE.ALREADY_RUNNING))
        {
            resBody='{"@type": "error","code": "REPO_17315","description": "Linear Taskflow failed to run. Another instance of the Linear Taskflow is currently running.","statusCode": 403}';
            statusCode=403;
        }else if(cType.equals(TYPE.GLOBAL_ERROR))
        {//Any error other than 200 is considered as an internal error
            statusCode=400;
        }else if(cType.equals(TYPE.INFORMATICA_ERROR))
        {
            statusCode=403;
            resBody='{"@type": "error","code": "REPO_12345","description": "Some error occurred at informatica site","statusCode": 403}';
            
        }
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(resBody);
        res.setStatusCode(statusCode);
        return res;
    }
}