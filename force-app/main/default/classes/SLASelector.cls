public without sharing class SLASelector {
    
    public static List<SLA__c> getDueSLAsOfLeads() {
        return [
            SELECT Id, DataHoraVencimento__c, FaseRedirecionamento__c, FilaRedirecionamento__c, 
                Lead__c, TempoLimitePerdaMinutos__c, LimitePercentualAmarelo__c, LimitePercentualVerde__c,
                Lead__r.RecordType.DeveloperName, Objeto__c
            FROM SLA__c
            WHERE DataHoraVencimento__c <= :System.now()
                AND Executado__c = false
                AND Lead__c != null
        ];
    } 

    public static List<SLA__c> getWarningSLAsOfLeads() {
        return [
            SELECT Id, FarolDoLeadTexto__c, DataHoraVencimento__c, TempoLimitePerdaMinutos__c, TempoRestanteMinutos__c,
                Lead__r.OwnerId, Lead__r.Name, SLA__c.NotificacaoAmarelaEnviada__c, SLA__c.NotificacaoVermelhaEnviada__c
            FROM SLA__c
            WHERE Lead__c != null
                AND FarolDoLeadTexto__c IN ('Amarelo', 'Vermelho')
                AND Lead__r.Owner.Type IN ('User')
                AND (NotificacaoAmarelaEnviada__c = false
                OR NotificacaoVermelhaEnviada__c = false)
        ];
    } 

    public static List<SLA__c> getDueSLAsByLeadIds(Set<Id> leadIds) {
        return [
            SELECT Id, DataHoraVencimento__c, FaseRedirecionamento__c, FilaRedirecionamento__c, 
                Lead__c, TempoLimitePerdaMinutos__c, LimitePercentualAmarelo__c, LimitePercentualVerde__c,
                Lead__r.RecordType.DeveloperName, Objeto__c
            FROM SLA__c
            WHERE DataHoraVencimento__c <= :System.now()
                AND Executado__c = false
                AND Lead__c IN :leadIds
        ];
    } 

    public static List<SLA__c> getCurrentSLAsByLeadIds(Set<Id> leadIds) {
        return [
            SELECT Id, DataHoraVencimento__c, FaseRedirecionamento__c, FilaRedirecionamento__c, 
                Lead__c, TempoLimitePerdaMinutos__c, LimitePercentualAmarelo__c, LimitePercentualVerde__c,
                Lead__r.RecordType.DeveloperName, Objeto__c
            FROM SLA__c
            WHERE Executado__c = false
                AND Lead__c IN :leadIds
        ];
    } 
}