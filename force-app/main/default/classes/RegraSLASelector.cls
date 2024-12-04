public without sharing class RegraSLASelector {

    public static List<RegraSLA__c> getLeadSLARules() {
        return [
            SELECT
                Id, Name, FaseRedirecionamento__c, FilaRedirecionamento__c, FaseAplicacao__c,
                LimitePercentualAmarelo__c, LimitePercentualVerde__c, Objeto__c, TempoLimitePerdaMinutos__c,
                RecordType.DeveloperName
            FROM RegraSLA__c
            WHERE Objeto__c = 'Lead'
        ];
    }

}