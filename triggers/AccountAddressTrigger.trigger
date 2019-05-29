trigger AccountAddressTrigger on Account (before insert, before update) {


        for (Account a : Trigger.new) {
            if( (a.Match_Billing_Address__c) && !String.isBlank(a.BillingPostalCode)){
                 a.ShippingPostalCode = a.BillingPostalCode;
            }
                        
         }
    
}