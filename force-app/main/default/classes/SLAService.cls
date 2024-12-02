public without sharing class SLAService {

    public static final String REGRA_SLA_NORTIS_RECORD_TYPE_DEVELOPER_NAME = 'RegraSLANortis';
    public static final String REGRA_SLA_VIBRA_RECORD_TYPE_DEVELOPER_NAME = 'RegraSLANortis';
    public static final List<RegraSLA__c> SLA_RULES = RegraSLASelector.getLeadSLARules();
    private static final List<Group> LEAD_QUEUES = GroupSelector.getLeadQueues();

    public static void createLeadSLAs(List<Lead> newLeads) {
        if (newLeads.isEmpty()) {
            return;
        }

        List<SLA__c> slasToCreate = new List<SLA__c>();

        for (Lead lead : newLeads) {
            
        }
    }

    public static void updateLeadSLAs(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        
    }

    public static SLA__c retriveLeadRequiredSLA(Lead lead) {
        if (lead == null) {
            return null;
        }

        for (RegraSLA__c slaRule : SLA_RULES) {
            String leadEntrerprise = lead.RecordType.DeveloperName.contains('Nortis') ? 'Nortis' : 'Vibra';
            String slaRuleEnterprise = slaRule.RecordType.DeveloperName.contains('Nortis') ? 'Nortis' : 'Vibra';

            if (lead.Status == slaRule.FaseAplicacao__c && leadEntrerprise == slaRuleEnterprise) {
                return new SLA__c(
                    Lead__c = lead.Id
                );
            }
        }

        return null;
    }

    public static void handleLeadSLAs() {
        List<SLA__c> leadsDueSLAs = SLASelector.getDueSLAsOfLeads();

        if (leadsDueSLAs.isEmpty()) {
            return;
        }

        executeDueLeadSLAs(leadsDueSLAs);
    }
    
    public static void executeDueLeadSLAs(List<SLA__c> dueSLAs) {
        if (dueSLAs.isEmpty()) {
            return;
        }

        List<Lead> leadsToUpdate = new List<Lead>();

        List<Group> leadQueues = GroupSelector.getLeadQueues();

        for (SLA__c sla : dueSLAs) {

            leadsToUpdate.add(new Lead(
                Id = sla.Lead__c,
                Status = sla.FaseRedirecionamento__c,
                OwnerId = getLeadQueueByName(sla.FilaRedirecionamento__c).Id
            ));

            sla.Executado__c = true;
        }

        update leadsToUpdate;
        update dueSLAs;
    }

    private static Group getLeadQueueByName(String name) {
        for (Group queue : LEAD_QUEUES) {
            if (queue.DeveloperName == name) {
                return queue;
            }
        }

        return null;
    }
}