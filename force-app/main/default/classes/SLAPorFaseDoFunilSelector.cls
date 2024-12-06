public without sharing class SLAPorFaseDoFunilSelector {

    public static List<SLAPorFaseDoFunil__c> getLeadSLAPerFunnelPhase() {
        return [
            SELECT
                Id, Name, FaseRedirecionamento__c, FilaRedirecionamento__c, FaseDoFunil__c,
                LimitePercentualAmarelo__c, LimitePercentualVerde__c, Objeto__c, TempoLimitePerdaMinutos__c,
                RecordType.DeveloperName
            FROM SLAPorFaseDoFunil__c
            WHERE Objeto__c = 'Lead'
        ];
    }

}