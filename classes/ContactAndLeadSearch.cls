public class ContactAndLeadSearch {
    public static List<List<sObject>> searchContactsAndLeads(string str1){
        
        List<List<sObject>> searchList = 
            [FIND :str1 IN ALL FIELDS RETURNING Lead(FirstName, LastName where FirstName = :str1 OR LastName = :str1 ),
             								   Contact(FirstName,LastName where FirstName = :str1 OR LastName = :str1)];
        Lead[] searchLeads = (Lead[])searchList[0];
        Contact[] searchContacts = (Contact[])searchList[1];
        System.debug('Found the following lead.');
        for (Lead a : searchLeads) {
            System.debug(a.FirstName + ', ' + a.LastName);
        }
        System.debug('Found the following contacts.');
        for (Contact c : searchContacts) {
            System.debug(c.LastName + ', ' + c.FirstName);
        }
        
		return searchList;        
    }
}