public class WFPaymentMgrController {

    public static List<WFPaymentMgrResponseBean> recentWfIntegrations{get; set;}
   // public static String sender {get; set;}

    @TestVisible
    private static final String GLOBAL_ERR_MSG='An internal error has occurred.Please contact System Administrator for assistance.';
    public WFPaymentMgrController()
    {
     //   sender = 'wellsfargo';
        try
        {
            WFPaymentMgrAPI.APIResponseBean sessionBean= WFPaymentMgrAPI.getInformaticaSessionId();
            String sessionResponse=sessionBean.responseType;

            System.debug('sessionResponse=='+sessionResponse);
            if(sessionResponse.equals('confirm'))
            {
                String icSessionId=(String)sessionBean.response;
                WFPaymentMgrAPI.APIResponseBean responseBean = WFPaymentMgrAPI.getRecentIntegrations(icSessionId,UserInfo.getTimeZone().getID());

                String type=responseBean.responseType;
                Object response=responseBean.response;
                if(type.equals('confirm'))
                {
                    recentWfIntegrations=(List<WFPaymentMgrResponseBean>)response;
                }else if(type.equals('info'))
                {
                    ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.INFO,(String)response));
                }else if(type.equals('error'))
                {
                    ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.ERROR,(String)response));
                }

            }else
            {
                ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.ERROR,(String)sessionBean.response));
            }

        }catch(Exception e)
        {
            ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.ERROR,GLOBAL_ERR_MSG));
            System.debug('Error Msg : '+e.getMessage()+' Line No '+e.getLineNumber()+'Stack Trace : '+e.getStackTraceString());
        }

    }

    private static ApexPages.Message getApexPgMsg(ApexPages.Severity severity, String msg)
    {
        ApexPages.Message apexMsg = new ApexPages.Message(severity,msg);
        ApexPages.addMessage(apexMsg);
        return apexMsg;
    }

    public static PageReference runWFIntegration()
    {
        try
        {
            WFPaymentMgrAPI.APIResponseBean sessionBean= WFPaymentMgrAPI.getInformaticaSessionId();
            String sessionResponse=sessionBean.responseType;

            if(sessionResponse.equals('confirm'))
            {
                String icSessionId=(String)sessionBean.response;

                WFPaymentMgrAPI.APIResponseBean responseBean = WFPaymentMgrAPI.runIntegration(icSessionId);

                String type=responseBean.responseType;
                String msg=(String)responseBean.response;
                if(type.equals('info'))
                {
                    ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.INFO,msg));
                }else if(type.equals('warning'))
                {
                    ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.WARNING,msg));
                }else if(type.equals('error'))
                {
                    ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.ERROR,msg));
                }

            }
            else
            {
                ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.ERROR,(String)sessionBean.response));
            }
        }catch(Exception e)
        {
            ApexPages.addMessage(getApexPgMsg(ApexPages.Severity.ERROR,GLOBAL_ERR_MSG));
            System.debug('Error Msg : '+e.getMessage()+' Line No '+e.getLineNumber());
        }
        return null;
    }

}