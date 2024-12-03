public without sharing class SLASelector {
    
    public static List<SLA__c> getDueSLAsOfLeads() {
        return [
            SELECT Id, DataHoraVencimento__c, FaseRedirecionamento__c, FilaRedirecionamento__c, 
                Lead__c, TempoLimitePerdaMinutos__c, LimitePercentualAmarelo__c, LimitePercentualVerde__c,
                Lead__r.RecordType.DeveloperName, Objeto__c
            FROM SLA__c
            WHERE DataHoraVencimento__c >= :System.now()
                AND Executado__c = false
                AND Lead__c != null
        ];
    } 

    public static List<SLA__c> getSLAsByLeadIds(Set<Id> leadIds) {
        return [
            SELECT Id, DataHoraVencimento__c, FaseRedirecionamento__c, FilaRedirecionamento__c, 
                Lead__c, TempoLimitePerdaMinutos__c, LimitePercentualAmarelo__c, LimitePercentualVerde__c,
                Lead__r.RecordType.DeveloperName, Objeto__c
            FROM SLA__c
            WHERE DataHoraVencimento__c >= :System.now()
                AND Executado__c = false
                AND Lead__c IN :leadIds
        ];
    } 

}