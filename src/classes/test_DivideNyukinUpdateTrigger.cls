@isTest public class test_DivideNyukinUpdateTrigger{
 static testMethod void myUnitTest(){
     //入居者
     List<Account> LAccount = new list<Account>();
     Account newAC1 = new Account(
        FirstName='太郎',
        LastName='テスト',
        M_Sex__c= '男'
     );
     LAccount.add(newAC1);
     insert LAccount;
     
     //物件
     List<Bukken__c> LBukken = new list<Bukken__c>();
     Bukken__c newBK1 = new Bukken__c(
        BukkenName__c='テスト物件'
     );
     LBukken.add(newBK1);
     insert LBukken;
     
     //契約
     List<Keiyaku__c> LKeiyaku = new list<Keiyaku__c>();
     Keiyaku__c newKY1 = new Keiyaku__c(
        Nyukyosha__c = newAC1.id,
        Bukken__c = newBK1.id,
        KeiyakuStart__c = date.newInstance(2015,7,1)
     );
     LKeiyaku.add(newKY1);
     insert LKeiyaku;
     
     //代位弁済
     List<DaiiBensai__c> LDaiiBensai = new list<DaiiBensai__c>();
     DaiiBensai__c newDB1 = new DaiiBensai__c(
        Keiyaku__c = newKY1.id,
        Rent_Money__c = 80000,
        made_day__c = date.newInstance(2015,7,1)
     );
     LDaiiBensai.add(newDB1);
     
     DaiiBensai__c newDB2 = new DaiiBensai__c(
        Keiyaku__c = newKY1.id,
        Rent_Money__c = 90000,
        made_day__c = date.newInstance(2015,8,1)
     );
     LDaiiBensai.add(newDB2);
     
     DaiiBensai__c newDB3 = new DaiiBensai__c(
        Keiyaku__c = newKY1.id,
        Rent_Money__c = 90000,
        made_day__c = date.newInstance(2015,9,1)
     );
     LDaiiBensai.add(newDB3);
     
     insert LDaiiBensai;
     
     //入金
     List<Nyukin__c> LNyukin = new list<Nyukin__c>();
     Nyukin__c newNY1 = new Nyukin__c(
        DaiiBensai__c = newDB1.id,
        NyukinKingaku__c = 70000
     );
     insert newNY1;
     
     Nyukin__c newNY2 = new Nyukin__c(
        DaiiBensai__c = newDB1.id,
        NyukinKingaku__c = 50000
     );
     insert newNY2;
     
     Nyukin__c newNY3 = new Nyukin__c(
        DaiiBensai__c = newDB2.id,
        NyukinKingaku__c = 200000
     );
     insert newNY3;
 }
 
 }