public with sharing class Sample {
    public Sample() {
        
    }
    public static void Sample{
        if(Schema.sObjectType.Account.isCreateable()){
            for(Account acc : accList){
                if(Schema.sObjectType.Account.fields.Description.isUpdateable()){
                    acc.Description = 'Happy Welcome';
                    acc.Rating = 'Hot';
                    acc.Industry = 'Agriculture';
                    System.debug('Welcome Happy');
                }
            }
            insert accList;
        } else {
            throw new CustomException('You do not have permission to create Account records.');
        }
    }
}