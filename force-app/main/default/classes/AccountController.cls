public with sharing class AccountController {
    public static void insertAccount(List<Account> accList){
        for(Account acc:accList){
            System.debug('AccountController');
            System.debug('AccountController Method');
            acc.Description='Happy Welcome';
        }
    }
    public static void insertAccountOpp(List<Account> accList){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Account acc:accList){
            Opportunity opp = new Opportunity();
            opp.Name = acc.name;
            opp.CloseDate = System.Today();
            opp.StageName = 'Prospecting';
            opp.AccountId = acc.id;
            oppList.add(opp);
        }
        if(oppList.size()>0){
            insert oppList;
        }
    }
}
