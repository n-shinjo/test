@isTest
private class TestDaiiBensaiBillPDF {

    static testMethod void myUnitTest() {
        Account 	acc = new Account(
                                                        R_Name__c = '連帯保証人1'
                                                        ,R_Name2__c = '連帯保証人2'
														,LastName = '姓'
            											,FirstName = '名'
        									);
		insert acc;


        Bukken__c 	bukken = new Bukken__c(
            											BukkenName__c  = 'T物件'
        											);
		insert bukken;


        Keiyaku__c keiyaku = new Keiyaku__c(
            											Nyukyosha__c = acc.Id
            											,Bukken__c  = bukken.Id
            											,Billing_Date__c = date.valueOf('2015-01-01')
            											,Billing_Type__c  = '連帯保証人1'
            											,Goshitu__c = '201号室'
        											);
        insert keiyaku;
        
        //	NyukinKingaku__c 

        DaiiBensai__c  daiiBensai = new DaiiBensai__c(
            											Keiyaku__c  = keiyaku.id
                        								,made_day__c   = Date.valueOf ('2015-04-01')
             											,Rent_Money__c = 1000
             											,Common_Fee__c = 1000
             											,Health_Costs__c = 1000
             											,Water_Fee__c = 1000
             											,Parking_lot__c = 1000
             											,Toku_Roku__c = 1000
        											);
        insert daiiBensai;
        
        Nyukin__c 	nyukin =  new Nyukin__c(
            											DaiiBensai__c  = daiiBensai.id
            											,NyukinKingaku__c = 1000
            											,Nyukinbi__c  = Date.valueOf ('2015-04-01')
        											);
        
        insert nyukin;

        // Apex Extensions Class
        Apexpages.StandardController sc = new Apexpages.standardController( keiyaku );
        DaiiBensaiBillPDF ec = new DaiiBensaiBillPDF( sc );
    }

}