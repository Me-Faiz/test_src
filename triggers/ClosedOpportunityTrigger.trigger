trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {

    List<Task> taskList = new List<Task>();
    for (Opportunity a : [SELECT Id,Name FROM Opportunity
                     WHERE Id IN :Trigger.New AND StageName = 'Closed Won']) {
        // Add a default opportunity for this account
        taskList.add(new Task(WhatId=a.Id, Subject = 'Follow Up Test Task')); 
                         
    }
    
    if (taskList.size() > 0) {
        insert taskList;
    }
    
}