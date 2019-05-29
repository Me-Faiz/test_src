trigger WellsFargoAuditChange on WellsFargoAudit__c (after update) {
//  List<WellsFargoAudit__c> auditList = Trigger.Old;
//    List<Task> taskList = new List<Task>();

    
    for (WellsFargoAudit__c a : Trigger.New ) {
        WellsFargoAudit__c oldAudit = Trigger.oldMap.get(a.Id);
        if(a.Status__c == 'Completed' && oldAudit.Status__c == 'Started'){
            System.debug('Completed Job.');
        } else if(a.Status__c == 'Failed' && oldAudit.Status__c == 'Started'){
            System.debug('Failed Job.');
        }
                         
    }

}