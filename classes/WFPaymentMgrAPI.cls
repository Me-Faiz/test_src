public class WFPaymentMgrAPI {

    private static final String CONTENT_TYPE_JSON='application/json';
    private static String INFORMATICA_LOGIN_URL='';
    private static String INFORMATICA_USERNAME='';
    private static String INFORMATICA_PASSWORD='';
    private static String INFORMATICA_RUN_JOB_URL='';
    private static String INFORMATICA_ACTIVITY_LOG_URL='';
    private static String WF_TASK_ID='';
    private static Integer WF_ROW_LIMIT=0;
    private static String WF_TASK_NAME='';
    private static String WF_DS_NAME='';
    private static final String WF_CRED_NAME='WF_Payment_Manager_Credential';
    private static final String RECENT_INTEGRATION_CONFIG='Recent_Integrations_Config';

    private static Map<Integer,String> stateStatusMap=new Map<Integer,String>{1 => 'Success', 2 => 'Warning', 3 => 'Failed'};
    @TestVisible
    private static final String MSG_INTEGRATION_STARTED='Job has been started successfully. Details will be available once the job completes.';
    @TestVisible
    private static final String MSG_INFORMATICA_RETURNED='Informatica Returned : ';
    @TestVisible
    private static final String MSG_INFORMATICA_AUTH_ERROR='Authentication Error when communicating with Informatica.';
    @TestVisible
    private static final String MSG_INTERNAL_ERROR='An internal error occurred when communicating with Informatica.';
    @TestVisible
    private static final String MSG_NO_RECENT_INTEGRATIONS='There are no new recent integrations available to show.';

    private static String DATA_TIME_FMT='MMM dd yyyy, h:mm a';
    private static String RECENT_WF_INTEGRATIONS_ENDPOINT='';
    @TestVisible
    private static String MSG_WF_ALREADY_RUNNING='The Wells Fargo Payment Manager Integration failed to run. Another instance of the integration is currently running.';
    private static String WF_ALREADY_RUNNING_ERROR_CODE='REPO_17315';

    private static final String ALREADY_RUNNING = 'Linear Taskflow failed to run. Another instance of the Linear Taskflow is currently running.';

    private static String key = '$B&E)H@McQfTjWmZ';
    private static String vector='wellsfargovector';
    private static String encryptAlogorithm = 'AES128';
    private static EncryptionUtil encryptionUtil;
   static {
        encryptionUtil=new EncryptionUtil(encryptAlogorithm,key,vector);

        Informatica_Credentials__mdt cred=WFPaymentMgrDBService.getInformaticaCredential(WF_CRED_NAME);
        INFORMATICA_LOGIN_URL= cred.Login_URL__c;
        INFORMATICA_USERNAME= cred.Username__c;
        INFORMATICA_PASSWORD= encryptionUtil.decrypt(cred.Password__c);
        System.debug('password from custom meta data=='+INFORMATICA_PASSWORD);
        List<WF_Payment_Manager_URL_Config__mdt> urlConfigs=WFPaymentMgrDBService.getAllURLConfig();
        for(WF_Payment_Manager_URL_Config__mdt urlConfig:urlConfigs)
        {
            if(urlConfig.DeveloperName.equals('Informatica_Activity_Log_URL'))
            {
                INFORMATICA_ACTIVITY_LOG_URL=urlConfig.Endpoint_URL__c;
            }else if(urlConfig.DeveloperName.equals('Informatica_Run_Job_URL'))
            {
                INFORMATICA_RUN_JOB_URL=urlConfig.Endpoint_URL__c;
            }
        }

        WF_Integration_Config__mdt recentIntegrationConfig=
                WFPaymentMgrDBService.getWFIntegrationConfig(RECENT_INTEGRATION_CONFIG);

        WF_TASK_ID= recentIntegrationConfig.Task_ID__c;
        WF_ROW_LIMIT=Integer.valueOf(recentIntegrationConfig.Row_Limit__c);
        WF_TASK_NAME= recentIntegrationConfig.Task_Name__c;
        WF_DS_NAME = recentIntegrationConfig.DS_Name__c;
        RECENT_WF_INTEGRATIONS_ENDPOINT=INFORMATICA_ACTIVITY_LOG_URL+'?taskId='+WF_TASK_ID+'&rowLimit='+WF_ROW_LIMIT;

    }

    public class APIResponseBean
    {
        public String responseType {get; set;}
        public Object response {get; set;}
        public APIResponseBean(String responseType,Object response)
        {
            this.responseType = responseType;
            this.response = response;
        }
    }



    //  private static EncryptionUtil encryptionUtil=new EncryptionUtil(encryptAlogorithm,key,vector);

    public static String encryptText(String txt)
    {
        String encryptedText=encryptionUtil.encrypt(txt);
        return encryptedText;
    }

    public static String decryptText(String txt)
    {
        return encryptionUtil.decrypt(txt);
    }

    private static String getLoginResponseBody()
    {

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('username',INFORMATICA_USERNAME);
        gen.writeStringField('password',INFORMATICA_PASSWORD);
        gen.writeStringField('@type','login');

        gen.writeEndObject();
        return gen.getAsString();

    }
    private static String getReqBodyToRunIntegration()
    {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('@type','job');
        gen.writeStringField('taskName', WF_TASK_NAME);
        gen.writeStringField('taskType','WORKFLOW');
        gen.writeEndObject();


        return gen.getAsString();

    }

    public static APIResponseBean getInformaticaSessionId()
    {
        APIResponseBean bean=null;
        String icSessionId='';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(INFORMATICA_LOGIN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', CONTENT_TYPE_JSON);
        req.setBody(getLoginResponseBody());
        HttpResponse response = http.send(req);
        System.debug('getInformaticaSessionId Response: '+response);
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            icSessionId=results.get('icSessionId').toString();
            bean= new APIResponseBean('confirm', icSessionId);
        }else
        {
            bean= new APIResponseBean('error', MSG_INFORMATICA_AUTH_ERROR);
        }

        return bean;

    }

    public static APIResponseBean runIntegration(String icSessionId)
    {
        APIResponseBean bean=null;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(INFORMATICA_RUN_JOB_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', CONTENT_TYPE_JSON);
        req.setHeader('icSessionId', icSessionId);
        String reqBody=getReqBodyToRunIntegration();
        req.setBody( reqBody);
        HttpResponse response = http.send(req);
        Map<String, Object> results = null;
        if (response.getStatusCode() == 200) {
            results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if(results.containsKey('taskId'))
            {
                bean=new APIResponseBean('info', MSG_INTEGRATION_STARTED);
            }
        }else if(response.getStatusCode() == 403)
        {
            results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            String description=(String)results.get('description');
            String code=(String)results.get('code');

            String msg='';
            if(code.equals(WF_ALREADY_RUNNING_ERROR_CODE))
            {
                msg=MSG_WF_ALREADY_RUNNING;
            }
            else
            {
                msg=MSG_INFORMATICA_RETURNED+description+' Error Code : '+code;
            }
            bean=new APIResponseBean('warning', msg);
        }
        else
        {
            bean=new APIResponseBean('error', MSG_INTERNAL_ERROR);
        }

        return bean;
    }



    private static String getInUserTime(String dtStr,String userTzId)
    {
        return convertStrToDt(dtStr).format(DATA_TIME_FMT,
                userTzId);
    }

    //dtStr => '2018-12-17T06:32:16.000Z';
    private static Datetime convertStrToDt(String dtStr)
    {
        String dateTimeStr = dtStr.substring(0, dtStr.indexOf('T'));

        String[] splittedDate=dateTimeStr.split('-');

        String timeStr=dtStr.substring(dtStr.indexOf('T')+1,dtStr.indexOf('.'));

        String[] splittedTime=timeStr.split(':');

        Datetime gmtDate = Datetime.newInstanceGmt(Integer.valueOf(splittedDate[0]),
                Integer.valueOf(splittedDate[1]),
                Integer.valueOf(splittedDate[2]),
                Integer.valueOf(splittedTime[0]),
                Integer.valueOf(splittedTime[1]),
                Integer.valueOf(splittedTime[2]));

        return gmtDate;
    }



    public static APIResponseBean getRecentIntegrations(String icSessionId,String userTzId)
    {
        APIResponseBean bean=null;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(RECENT_WF_INTEGRATIONS_ENDPOINT);
        req.setMethod('GET');
        req.setHeader('icSessionId', icSessionId);
        HttpResponse response = http.send(req);

        List<WFPaymentMgrResponseBean> recentWfIntegrations = new List<WFPaymentMgrResponseBean>();

        System.debug('getRecentIntegrations Response Status Code : '+response.getStatusCode());
        if (response.getStatusCode() == 200) {
            List<Object> activityLogs = (List<Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('activityLogs=='+activityLogs);
            for(Object activityLog : activityLogs){

                Map<String, Object> activityLogMap = (Map<String, Object>) activityLog;
                WFPaymentMgrResponseBean wfBean = new WFPaymentMgrResponseBean();

                String startTimeUTCFromWf=(String)activityLogMap.get('startTimeUtc');
                wfBean.startTimeUtc = getInUserTime(startTimeUTCFromWf,userTzId);

                String endTimeUTCFromWf =(String)activityLogMap.get('endTimeUtc');
                wfBean.endTimeUtc =getInUserTime(endTimeUTCFromWf,userTzId);

                String runContextType=(String)activityLogMap.get('runContextType');
                wfBean.runContextType = runContextType;

                String errorMsg=(String)activityLogMap.get('errorMsg');


                System.debug('Kamal Boss' + errorMsg);


                System.debug('String.isNotBlank(errorMsg) '+String.isNotBlank(errorMsg) );
                System.debug('String.2nd(errorMsg) '+ALREADY_RUNNING.equals(errorMsg));

                System.debug(ALREADY_RUNNING +'   '+ errorMsg);

                if (String.isNotBlank(errorMsg)  && ALREADY_RUNNING.equals(errorMsg)) {
                    errorMsg = MSG_WF_ALREADY_RUNNING;
                    System.debug('Hhelloooo hellooooo');
                }else{
                    System.debug('Meooooowwwwwww');
                }
                wfBean.errorMsg = errorMsg;

                Integer state=(Integer)activityLogMap.get('state');
                wfBean.status = stateStatusMap.get(state);

                List<Object> entries= (List<Object>)activityLogMap.get('entries');
                for(Object entry:entries)
                {
                    Map<String, Object> entryMap = (Map<String, Object>) entry;
                    String objName= (String)entryMap.get('objectName');
                    if(objName.equals(WF_DS_NAME))
                    {
                        wfBean.filesProcessed = (Integer)entryMap.get('successTargetRows');
                    }

                }

                recentWfIntegrations.add(wfBean);
            }

            /* Uncomment below line to check no recent orders flow */
            //recentWfIntegrations=new List<WFPaymentMgrResponseBean>();
            if(recentWfIntegrations.size()==0)
            {
                bean=new APIResponseBean('info', MSG_NO_RECENT_INTEGRATIONS);
            }else
            {
                bean=new APIResponseBean('confirm', recentWfIntegrations);
            }

        }
        else
        {
            bean=new APIResponseBean('error', MSG_INTERNAL_ERROR);
        }


        return bean;

    }

}