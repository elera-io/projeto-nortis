public without sharing class SLAService {

    private static final List<RegraSLA__c> SLA_RULES = RegraSLASelector.getLeadSLARules();

    private static final List<Group> LEAD_QUEUES = GroupSelector.getLeadQueues();

    public static void createLeadSLAs(List<Lead> newLeads) {
        
    }

    public static void updateLeadSLAs(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        
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