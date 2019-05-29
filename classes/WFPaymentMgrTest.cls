@IsTest
public class WFPaymentMgrTest {
    private static final String WF_CRED_NAME='WF_Payment_Manager_Credential';
    private static final String RECENT_INTEGRATION_CONFIG='Recent_Integrations_Config';
    private static String LOGIN_URL='';   
    private static String RUN_JOB_URL='';
    private static String ACTIVITY_LOG_URL='';
    private static String RECENT_INTEGRATIONS_URL='';

    private static void testSetup() {
        Informatica_Credentials__mdt cred=WFPaymentMgrDBService.getInformaticaCredential(WF_CRED_NAME); 
        LOGIN_URL=cred.Login_URL__c;
        
        List<WF_Payment_Manager_URL_Config__mdt> urlConfigs=WFPaymentMgrDBService.getAllURLConfig();
        for(WF_Payment_Manager_URL_Config__mdt urlConfig:urlConfigs)
        {
            if(urlConfig.DeveloperName.equals('Informatica_Activity_Log_URL'))
            {
                ACTIVITY_LOG_URL=urlConfig.Endpoint_URL__c;
            }else if(urlConfig.DeveloperName.equals('Informatica_Run_Job_URL'))
            {
                RUN_JOB_URL=urlConfig.Endpoint_URL__c;
            }
        }
        
        WF_Integration_Config__mdt recentIntegrationConfig= 
            WFPaymentMgrDBService.getWFIntegrationConfig(RECENT_INTEGRATION_CONFIG);
        
        RECENT_INTEGRATIONS_URL=ACTIVITY_LOG_URL+'?taskId='+recentIntegrationConfig.Task_ID__c+'&rowLimit='+Integer.valueOf(recentIntegrationConfig.Row_Limit__c);
        
        
    }
    
    
    private static WFPaymentMgrHTTPMock getMocks(String loginURL,
                                                 WFLoginMockResp.TYPE loginType,String integrationURL,
                                                 WFIntegrationMockResp.TYPE integrationType)
    {
        WFLoginMockResp loginMock=new WFLoginMockResp(loginType);
        WFIntegrationMockResp integrationMock=new WFIntegrationMockResp(integrationType);
        
        Map<String, HttpCalloutMock> mocks =
            new Map<String,HttpCalloutMock>();
        mocks.put(loginURL,loginMock);
        mocks.put(integrationURL,integrationMock);
        
        return new WFPaymentMgrHTTPMock(mocks);
        
    }
    @IsTest static void testGettingRecentOrdersOnPageLoad() {
        
        testSetup();
        
        Test.setMock(HttpCalloutMock.class, 
                     getMocks(LOGIN_URL,WFLoginMockResp.TYPE.SUCCESS,
                              RECENT_INTEGRATIONS_URL,WFIntegrationMockResp.TYPE.GET));
        WFPaymentMgrController controller=new WFPaymentMgrController();
        
        List<WFPaymentMgrResponseBean> recentIntegration=WFPaymentMgrController.recentWfIntegrations;
        
        System.assertEquals(1, recentIntegration.size());
        System.assertEquals(7, recentIntegration.get(0).filesProcessed);     
        System.assertEquals('Success',recentIntegration.get(0).status );
        
    }

    @IsTest static void testNoRecentIntegrations() {
        testSetup();

        Test.setMock(HttpCalloutMock.class, 
                     getMocks(LOGIN_URL, WFLoginMockResp.TYPE.SUCCESS,
                              RECENT_INTEGRATIONS_URL,WFIntegrationMockResp.TYPE.NO_RECENT));
        WFPaymentMgrController controller=new WFPaymentMgrController();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        System.assertEquals(WFPaymentMgrAPI.MSG_NO_RECENT_INTEGRATIONS,
                            pageMessages.get(0).getSummary());
        
    }
    
    @IsTest static void testRunningIntegration() {
        testSetup();

        Test.setMock(HttpCalloutMock.class, 
                     getMocks(LOGIN_URL, WFLoginMockResp.TYPE.SUCCESS,
                              RUN_JOB_URL,WFIntegrationMockResp.TYPE.RUN));        
        WFPaymentMgrController.runWFIntegration();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        System.assertEquals(WFPaymentMgrAPI.MSG_INTEGRATION_STARTED,
                            pageMessages.get(0).getSummary());
        
    }
    
    @IsTest static void testAlreadyRunningIntegration() {
        testSetup();
        Test.setMock(HttpCalloutMock.class, 
                     getMocks(LOGIN_URL,
                              WFLoginMockResp.TYPE.SUCCESS,RUN_JOB_URL,
                              WFIntegrationMockResp.TYPE.ALREADY_RUNNING));
        
        WFPaymentMgrController.runWFIntegration();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        System.assertEquals(WFPaymentMgrAPI.MSG_WF_ALREADY_RUNNING,
                            pageMessages.get(0).getSummary());
        
    }
    
    @IsTest static void testBadReqWhenRunningIntegration() {
        testSetup();
        Test.setMock(HttpCalloutMock.class,
                     getMocks(LOGIN_URL,
                              WFLoginMockResp.TYPE.SUCCESS,RUN_JOB_URL,
                              WFIntegrationMockResp.TYPE.GLOBAL_ERROR));
        
        WFPaymentMgrController.runWFIntegration();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        System.assertEquals(WFPaymentMgrAPI.MSG_INTERNAL_ERROR,
                            pageMessages.get(0).getSummary());
        
    }
    
    @IsTest static void testInformaticaErrors() {
        testSetup();
        Test.setMock(HttpCalloutMock.class,
                     getMocks(LOGIN_URL,
                              WFLoginMockResp.TYPE.SUCCESS,RUN_JOB_URL,
                              WFIntegrationMockResp.TYPE.INFORMATICA_ERROR));
        
        WFPaymentMgrController.runWFIntegration();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        System.assertEquals(true,
                            pageMessages.get(0).getSummary().startsWith(WFPaymentMgrAPI.MSG_INFORMATICA_RETURNED));
        
        
    }
    
    @IsTest static void testBadReqWhenGettingRecentIntegrations() {
        testSetup();
        Test.setMock(HttpCalloutMock.class,
                     getMocks(LOGIN_URL,
                              WFLoginMockResp.TYPE.SUCCESS,RECENT_INTEGRATIONS_URL,
                              WFIntegrationMockResp.TYPE.GLOBAL_ERROR));
        
        WFPaymentMgrController controller=new WFPaymentMgrController();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        System.assertEquals(WFPaymentMgrAPI.MSG_INTERNAL_ERROR,
                            pageMessages.get(0).getSummary());
        
    }
    
    
     @IsTest static void testAuthErrorWhenGettingRecentIntegrations() {
        
        testSetup();
        
        Test.setMock(HttpCalloutMock.class, 
                     getMocks(LOGIN_URL,WFLoginMockResp.TYPE.AUTH_ERROR,
                              RECENT_INTEGRATIONS_URL,WFIntegrationMockResp.TYPE.GET));
        WFPaymentMgrController controller=new WFPaymentMgrController();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        System.assertEquals(WFPaymentMgrAPI.MSG_INFORMATICA_AUTH_ERROR,
                            pageMessages.get(0).getSummary());
               
    }
    
     @IsTest static void testAuthErrorWhenRunningIntegrations() {
        
        testSetup();
        
        Test.setMock(HttpCalloutMock.class, 
                     getMocks(LOGIN_URL,WFLoginMockResp.TYPE.AUTH_ERROR,
                              RUN_JOB_URL,WFIntegrationMockResp.TYPE.RUN));
        WFPaymentMgrController.runWFIntegration();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        System.assertEquals(WFPaymentMgrAPI.MSG_INFORMATICA_AUTH_ERROR,
                            pageMessages.get(0).getSummary());
               
    }



    @IsTest static void testGlobalErrorOnPageLoad() {
        WFPaymentMgrController controller=new WFPaymentMgrController();

        //It will throw  Methods defined as TestMethod do not support Web service callouts since
        //we didnt set mock class
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        System.assertEquals(WFPaymentMgrController.GLOBAL_ERR_MSG, pageMessages.get(0).getSummary());

    }

    @IsTest static void testGlobalErrorOnRunningIntegration() {
        WFPaymentMgrController.runWFIntegration();

        //It will throw  Methods defined as TestMethod do not support Web service callouts since
        //we didnt set mock class
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        System.assertEquals(WFPaymentMgrController.GLOBAL_ERR_MSG, pageMessages.get(0).getSummary());

    }

    @IsTest static void testEncryption() {

        String pswd='password';
        String encryptedTxt=WFPaymentMgrAPI.encryptText(pswd);
        String decryptedTxt= WFPaymentMgrAPI.decryptText(encryptedTxt);

        System.assertEquals(decryptedTxt, pswd);


    }

    
}