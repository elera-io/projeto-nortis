public without sharing class SLAService {

    public static final String REGRA_SLA_NORTIS_RECORD_TYPE_DEVELOPER_NAME = 'RegraSLANortis';
    public static final String SLA_NORTIS_RECORD_TYPE_DEVELOPER_NAME = 'SLANortis';
    public static final String REGRA_SLA_VIBRA_RECORD_TYPE_DEVELOPER_NAME = 'RegraSLAVibra';
    public static final String SLA_VIBRA_RECORD_TYPE_DEVELOPER_NAME = 'SLAVibra';
    public static final List<RegraSLA__c> SLA_RULES = RegraSLASelector.getLeadSLARules();
    private static final List<Group> LEAD_QUEUES = GroupSelector.getLeadQueues();

    public static void createLeadSLAs(List<Lead> newLeads) {
        if (newLeads.isEmpty()) {
            return;
        }

        List<SLA__c> slasToCreate = new List<SLA__c>();

        for (Lead lead : newLeads) {
            SLA__c leadSLA = retriveLeadRequiredSLA(lead);

            if (leadSLA != null) {
                slasToCreate.add(leadSLA);
            }
        }

        if (!slasToCreate.isEmpty()) {
            insert slasToCreate;
        }
    }

    public static void updateLeadSLAs(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        if (newLeads.isEmpty()) {
            return;
        }

        Map<Id, Lead> leadsWithUpdatedStatus = new Map<Id, Lead>();

        for (Lead lead : newLeads) {
            if(lead.Status != oldLeadsMap.get(lead.Id).Status) {
                leadsWithUpdatedStatus.put(lead.Id, lead);
            }
        }

        if (leadsWithUpdatedStatus.isEmpty()) {
            return;
        }

        delete [SELECT Id FROM SLA__c WHERE Lead__c IN :leadsWithUpdatedStatus.keySet()];
        createLeadSLAs(leadsWithUpdatedStatus.values());
    }

    public static void restartLeadSLAByEvent(List<Event> events) {
        if (events.isEmpty()) {
            return;
        }

        Map<Id, DateTime> leadIdsWithEventEndDateTimes = new Map<Id, DateTime>();
        
        for (Event event : events) {
            if (event.WhoId != null && event.WhoId.getSObjectType() == Schema.Lead.SObjectType) {
                leadIdsWithEventEndDateTimes.put(event.WhoId, event.EndDateTime);
            }
        }

        if (leadIdsWithEventEndDateTimes.isEmpty()) {
            return;
        }

        restartLeadSLA(leadIdsWithEventEndDateTimes);
    }

    public static void restartLeadSLAByTask(List<Task> tasks) {
        if (tasks.isEmpty()) {
            return;
        }

        Map<Id, DateTime> leadIdsWithTasksEndDateTimes = new Map<Id, DateTime>();
        
        for (Task task : tasks) {
            if (task.WhoId != null && task.WhoId.getSObjectType() == Schema.Lead.SObjectType) {
                leadIdsWithTasksEndDateTimes.put(task.WhoId, task.ActivityDate);
            }
        }

        if (leadIdsWithTasksEndDateTimes.isEmpty()) {
            return;
        }

        restartLeadSLA(leadIdsWithTasksEndDateTimes);
    }

    private static void restartLeadSLA(Map<Id, DateTime> leadIdsWithEndDateTimes) {
        if (leadIdsWithEndDateTimes.isEmpty()) {
            return;
        }

        List<SLA__c> leadSLAs = SLASelector.getSLAsByLeadIds(leadIdsWithEndDateTimes.keySet());

        for (SLA__c sla : leadSLAs) {
            sla.DataHoraVencimento__c = leadIdsWithEndDateTimes.get(sla.Lead__c).addMinutes((Integer) sla.TempoLimitePerdaMinutos__c);
        }

        update leadSLAs;
    }

    public static SLA__c retriveLeadRequiredSLA(Lead lead) {
        if (lead == null) {
            return null;
        }

        for (RegraSLA__c slaRule : SLA_RULES) {
            String leadEntrerprise = Schema.SObjectType.Lead.getRecordTypeInfosById().get(lead.RecordTypeId).getDeveloperName().contains('Nortis') ? 'Nortis' : 'Vibra';
            String slaRuleEnterprise = slaRule.RecordType.DeveloperName.contains('Nortis') ? 'Nortis' : 'Vibra';

            if (lead.Status == slaRule.FaseAplicacao__c && leadEntrerprise == slaRuleEnterprise) {
                return new SLA__c(
                    Lead__c = lead.Id,
                    DataHoraVencimento__c = System.now().addMinutes((Integer) slaRule.TempoLimitePerdaMinutos__c),
                    FaseRedirecionamento__c = slaRule.FaseRedirecionamento__c,
                    FilaRedirecionamento__c = slaRule.FilaRedirecionamento__c,
                    TempoLimitePerdaMinutos__c = slaRule.TempoLimitePerdaMinutos__c,
                    FaseAplicacao__c = slaRule.FaseAplicacao__c,
                    LimitePercentualAmarelo__c = slaRule.LimitePercentualAmarelo__c,
                    LimitePercentualVerde__c = slaRule.LimitePercentualVerde__c,
                    Objeto__c = slaRule.Objeto__c,
                    RecordTypeId = Schema.SObjectType.SLA__c.getRecordTypeInfosByDeveloperName().get(
                        slaRuleEnterprise == 'Nortis' 
                        ? SLA_NORTIS_RECORD_TYPE_DEVELOPER_NAME 
                        : SLA_VIBRA_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId(),
                    Executado__c = false
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