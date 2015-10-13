trigger DivideNyukinUpdateTrigger on Nyukin__c (before insert) {
/**********************************************************************************
 * 残金<入金額の場合、入金データを分割してINSERT
 **********************************************************************************/
    Boolean actionFlg; //処理フラグ
    Boolean updateFlg = false; //上書きフラグ
    Id keiyakuId; //契約ID
    String targetYM; //INSERTした入金にひもづく代位弁済の対象年月
    String dbTargetYM; //取得した代位弁済の対象年月
    Integer dbZankin; //取得した代位弁済の残金
    Integer zankin; //残金
    Integer cnt = 0; //カウント
    
    Nyukin__c newrow = trigger.new[0];
    System.debug('newrow='+newrow);
    
    //1件のみの場合動作、複数件の場合は処理なし
    List<Nyukin__c > n= new List<Nyukin__c>();
    if(n.size() > 1){
        return;
    }
    
    //入金にひもづく代位弁済の残金を取得
     List<DaiiBensai__c> DBZ = new List<DaiiBensai__c>();
     DBZ = [
     select 
     Zankin2__c
     from 
     DaiiBensai__c
     where 
     id = :newrow.DaiiBensai__c 
     ];
     
     if(DBZ.size() > 0){
        for(DaiiBensai__c d:DBZ){
            dbZankin = (Integer)d.Zankin2__c;
        }
     }
     
     System.debug('dbZankin='+dbZankin);
    
    //残金<入金額か判定
    if(dbZankin < newrow.NyukinKingaku__c) {
        System.debug('残金 < 入金:処理あり');
        actionFlg = true;
    } else {
        System.debug('残金 >= 入金:処理なし');
        actionFlg = false;
    }
    
    //入金データ分割処理
    if(actionFlg){
         //契約のIDを取得
         List<DaiiBensai__c> DBK = new List<DaiiBensai__c>();
         DBK = [
         select 
         Keiyaku__c,
         DTaishoMonth__c
         from 
         DaiiBensai__c
         where 
         id = :newrow.DaiiBensai__c 
         ];
         
         if(DBK.size() > 0){
            for(DaiiBensai__c d:DBK){
                keiyakuId = d.Keiyaku__c;
                targetYM = d.DTaishoMonth__c;
            }
         }
         
         System.debug('keiyakuId='+keiyakuId);
         System.debug('targetYM='+targetYM);
         
         //取得した契約IDにひもづく代位弁済のIDを取得
         List<DaiiBensai__c> DBALL = new List<DaiiBensai__c>();
         DBALL = [
         select 
         id,
         DTaishoMonth__c,
         Zankin2__c
         from 
         DaiiBensai__c
         where 
         Keiyaku__c = :keiyakuId
         order by
         DTaishoMonth__c
         ];
        
        //次月の入金データを作成（以下ループ）
        zankin = (Integer)newrow.NyukinKingaku__c - dbZankin;
        List<Nyukin__c> NList = new List<Nyukin__c>();
        
        if(DBALL.size() > 0){
            for(DaiiBensai__c da:DBALL){
                targetYM = targetYM.replace('/','');
                System.debug('targetYM='+targetYM);
                
                dbtargetYM = da.DTaishoMonth__c;
                dbtargetYM = dbtargetYM.replace('/','');
                System.debug('dbtargetYM='+dbtargetYM);
                
                cnt = cnt + 1;
                
                if(Integer.valueOf(targetYM) < Integer.valueOf(dbtargetYM)){
                    
                    updateFlg = true;
                    Nyukin__c Nrow = new Nyukin__c();
                    
                    Nrow.GinkoName__c = newrow.GinkoName__c;
                    Nrow.DaiiBensai__c = da.id;
                    Nrow.Nyukinbi__c = newrow.Nyukinbi__c;
                    Nrow.Field1__c = newrow.Field1__c;
                    Nrow.Biko__c = newrow.Biko__c;
                    
                    //入金金額
                    if(zankin >= da.Zankin2__c && cnt <> DBALL.size()){
                        zankin = zankin - (Integer)da.Zankin2__c;
                        System.debug('zankin='+zankin);
                        Nrow.NyukinKingaku__c = da.Zankin2__c;
                        
                        Nlist.add(Nrow);
                        
                        //分割可能な金額がなくなったらループ終了
                        if(zankin <= 0){
                            break;
                        }
                    }else{
                        Nrow.NyukinKingaku__c = zankin;
                        
                        Nlist.add(Nrow);
                        break;
                    }
                }
            }
         }
         
        //当月の入金データを修正(入金金額=残金)
        if(updateFlg){
            newrow.NyukinKingaku__c = dbZankin;
        }
        
        //作成した入金データをINSERT
        System.debug('NList='+NList);
        insert NList;
        
    }
}