public class WFPaymentMgrDBService {
    
    public static Informatica_Credentials__mdt getInformaticaCredential(String name)
    {
        return [SELECT Id, DeveloperName, Login_URL__c, 
                Username__c, Password__c 
                FROM Informatica_Credentials__mdt 
                WHERE DeveloperName = :name];
    }
    
    public static  List<WF_Payment_Manager_URL_Config__mdt> getAllURLConfig()
    {
        return [SELECT Id, DeveloperName, Endpoint_URL__c 
                FROM WF_Payment_Manager_URL_Config__mdt];        
    }
    
    public static WF_Integration_Config__mdt getWFIntegrationConfig(String name)
    {      
        return [SELECT Id,DeveloperName,Task_ID__c ,
                Row_Limit__c , Task_Name__c , DS_Name__c                                        
                FROM WF_Integration_Config__mdt  
                WHERE DeveloperName = :name];
    }
    
    
}