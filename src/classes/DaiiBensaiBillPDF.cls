/**
 * 代位弁済の請求書(PDF)を表示(出力)するApexクラスです。
 *
 * タイプ ： 拡張コントローラー
 * 関連するオブジェクト ： 契約(Keiyaku),物件(Bukken),代位弁済(DaiiBensai)
 *
 * 変更履歴
 * 2015/07/21 N.Shinjo 新規作成
 * 2015/09/04 oshiro 項目追加に応じた対応
 */
public with sharing class DaiiBensaiBillPDF {
    public integer              Months {get;set;}

    public list<Date>           YearMonth {get;set;}

    public list<decimal>        Money_Kin {get;set;}

    public list<decimal>        NyukinKingaku {get;set;}
    public list<decimal>        Zankin2 {get;set;}
    public list<decimal>        Rent_Money {get;set;}
    public list<decimal>        Common_Fee {get;set;}
    public list<decimal>        Health_Costs {get;set;}
    public list<decimal>        Water_Fee {get;set;}
    public list<decimal>        Parking_lot {get;set;}
    public list<decimal>        Toku_Roku {get;set;}
    public list<decimal>        D_Month_Fee {get;set;}
    public list<String>         Add_Komoku {get;set;}			// 2015/09/04 oshiro 項目追加に応じた対応
    public String               Add_Komoku_Label {get;set;}		// 2015/09/04 oshiro 項目追加に応じた対応
    public list<decimal>        Add_Komoku_Money {get;set;}		// 2015/09/04 oshiro 項目追加に応じた対応

    public Date         siharaikijitu {get;set;} 
    public decimal      total_NyukinKingaku {get;set;}
    public decimal      total_Zankin2 {get;set;}
    public decimal      total_Rent_Money {get;set;}
    public decimal      total_Common_Fee {get;set;}
    public decimal      total_Health_Costs {get;set;}
    public decimal      total_Water_Fee {get;set;}
    public decimal      total_Parking_lot {get;set;}
    public decimal      total_Toku_Roku {get;set;}
    public decimal      total_D_Month_Fee {get;set;}
    public decimal      total_Add_Komoku_Money {get;set;}		// 2015/09/04 oshiro 項目追加に応じた対応

    public  Keiyaku__c keiyaku  { get; set; }

	public decimal ifnull(decimal num ) {
		if (num == null) num = 0;
		return num;
	}

    /**
     * コンストラクタ
     */
    public DaiiBensaiBillPDF( ApexPages.StandardController stdController ) {
        Keiyaku__c record = (Keiyaku__c)stdController.getRecord();

        YearMonth = new list<Date>{};
        Money_Kin = new list<Decimal>{};
        NyukinKingaku = new list<Decimal>{};
        Zankin2 = new list<Decimal>{};
        Rent_Money = new list<Decimal>{};
        Common_Fee = new list<Decimal>{};
        Health_Costs = new list<Decimal>{};
        Water_Fee = new list<Decimal>{};
        Parking_lot = new list<Decimal>{};
        Toku_Roku = new list<Decimal>{};
        D_Month_Fee = new list<Decimal>{};
        Add_Komoku = new list<String>{};			// 2015/09/04 oshiro 項目追加に応じた対応
        Add_Komoku_Money = new list<Decimal>{};		// 2015/09/04 oshiro 項目追加に応じた対応
        
        siharaikijitu = date.today();
        Months = 0;
        total_NyukinKingaku = 0;
        total_Zankin2 = 0;
        total_Rent_Money = 0;
        total_Common_Fee = 0;
        total_Health_Costs = 0;
        total_Water_Fee = 0;
        total_Parking_lot = 0;
        total_Toku_Roku = 0;
        total_D_Month_Fee = 0;
        total_Add_Komoku_Money = 0;		// 2015/09/04 oshiro 項目追加に応じた対応
        
        // ページのプレビューができるように配慮
        if  (record.Id == null) return;

        //    該当の契約データを取得（請求に関連する情報も同時に取得）
        List<Keiyaku__c> keiyakuList = Database.query(
            'select ' +
               'Nyukyosha__r.Name ' +
                ',Nyukyosha__r.R_Name__c ' + 
                ',Nyukyosha__r.R_Name2__c ' + 
                ',BukkenName__c ' +
                ',Billing_Date__c ' +
                ',Billing_Type__c  ' +
                ',Billing_Name__c  ' +
                ',Goshitu__c ' +
                    ',(select ' +
                        'DTaishoMonth__c ' +
                        ',Money_Kin__c ' +
                        ',NyukinKingaku__c ' +
                        ',Zankin2__c ' +
                        ',Rent_Money__c ' +
                        ',Common_Fee__c ' +
                        ',Health_Costs__c ' +
                        ',Water_Fee__c' +
                        ',Parking_lot__c' + 
                        ',Toku_Roku__c ' +
                        ',D_Month_Fee__c ' +
                        // 2015/09/04 oshiro 項目追加に応じた対応
                        ',Add_Komoku__c ' +
                        ',Add_Komoku_Money__c ' +
                      'from DaiiBensaiMmCH__r where Status__c  <> \'クローズ\' order by DTaishoMonth__c  asc) ' +
                    'from Keiyaku__c  ' +
            'where ' +
                'Id = \'' + record.Id + '\''
        );

        if (keiyakuList.size() <= 0) return;
        
        this.keiyaku = keiyakuList[0];

        List<DaiiBensai__c> DaiiBensaiList = this.keiyaku.DaiiBensaiMmCH__r;
        
        this.Months = DaiiBensaiList.size();

        for (integer i=0;i<this.Months;i++) {
            DaiiBensai__c   daiibensai = DaiiBensaiList.get(i);

            String wmon = ((String)daiibensai.DTaishoMonth__c).replace('/','-') + '-01';
            this.YearMonth.add(Date.valueOf(wmon));
            this.Money_Kin.add(ifnull(daiibensai.Money_Kin__c));
            this.NyukinKingaku.add(ifnull(daiibensai.NyukinKingaku__c) * -1);
            this.Zankin2.add(ifnull(daiibensai.Zankin2__c));
            this.Rent_Money.add(ifnull(daiibensai.Rent_Money__c));
            this.Common_Fee.add(ifnull(daiibensai.Common_Fee__c));
            this.Health_Costs.add(ifnull(daiibensai.Health_Costs__c));
            this.Water_Fee.add(ifnull(daiibensai.Water_Fee__c));
            this.Parking_lot.add(ifnull(daiibensai.Parking_lot__c));
            this.Toku_Roku.add(ifnull(daiibensai.Toku_Roku__c));
            this.D_Month_Fee.add(ifnull(daiibensai.D_Month_Fee__c));
 			if ( i == 0 ) {														// 2015/09/04 oshiro 項目追加に応じた対応
	 			this.Add_Komoku_Label = daiibensai.Add_Komoku__c;
 			}
            if ( daiibensai.Add_Komoku__c == null ) {							// 2015/09/04 oshiro 項目追加に応じた対応
	            this.Add_Komoku.add('');
            } else {
	            this.Add_Komoku.add(daiibensai.Add_Komoku__c);
            }
            this.Add_Komoku_Money.add(ifnull(daiibensai.Add_Komoku_Money__c));	// 2015/09/04 oshiro 項目追加に応じた対応

            total_NyukinKingaku += ifnull(daiibensai.NyukinKingaku__c) * -1;
            total_Zankin2 += ifnull(daiibensai.Zankin2__c);
            total_Rent_Money += ifnull(daiibensai.Rent_Money__c);
            total_Common_Fee += ifnull(daiibensai.Common_Fee__c);
            total_Health_Costs += ifnull(daiibensai.Health_Costs__c);
            total_Water_Fee += ifnull(daiibensai.Water_Fee__c);
            total_Parking_lot += ifnull(daiibensai.Parking_lot__c);
            total_Toku_Roku += ifnull(daiibensai.Toku_Roku__c);
            total_D_Month_Fee += ifnull(daiibensai.D_Month_Fee__c);
            total_Add_Komoku_Money += ifnull(daiibensai.Add_Komoku_Money__c);	// 2015/09/04 oshiro 項目追加に応じた対応
        }
 
        //    該当の契約データを取得（請求に関連する情報も同時に取得）
        List<AggregateResult> aggregateList = Database.query(
            'select max(siharaikijitu__c) siharaikijitu from DaiiBensai__c where Keiyaku__c =\'' + this.keiyaku.id + '\' and Status__c  <> \'クローズ\' ');

        siharaikijitu = date.valueOf(aggregateList[0].get('siharaikijitu'));
	}
}