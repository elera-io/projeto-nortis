public without sharing class SLAService {

    public static final String REGRA_SLA_NORTIS_RECORD_TYPE_DEVELOPER_NAME = 'RegraSLANortis';
    public static final String SLA_NORTIS_RECORD_TYPE_DEVELOPER_NAME = 'SLANortis';
    public static final String REGRA_SLA_VIBRA_RECORD_TYPE_DEVELOPER_NAME = 'RegraSLAVibra';
    public static final String SLA_VIBRA_RECORD_TYPE_DEVELOPER_NAME = 'SLAVibra';
    public static final List<SLAPorFaseDoFunil__c> SLA_PER_FUNNEL_PHASE = SLAPorFaseDoFunilSelector.getLeadSLAPerFunnelPhase();
    private static final List<Group> LEAD_QUEUES = GroupSelector.getLeadQueues();

    public static void createLeadSLAs(List<Lead> newLeads) {
        if (newLeads.isEmpty()) {
            return;
        }

        List<SLA__c> slasToCreate = new List<SLA__c>();

        for (Lead lead : newLeads) {
            SLA__c leadSLA = buildLeadRequiredSLA(lead);

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

        delete [SELECT Id FROM SLA__c WHERE Lead__c IN :leadsWithUpdatedStatus.keySet() AND Executado__c = false];
        createLeadSLAs(leadsWithUpdatedStatus.values());
    }

    public static void restartLeadSLAWithEvents(List<Event> events) {
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

    public static void restartLeadSLAWithEvents(List<Event> newEvents, Map<Id, Event> oldEventsMap) {
        if (newEvents.isEmpty() || oldEventsMap.isEmpty()) {
            return;
        }

        List<Event> eventsWithModifiedEndDate = new List<Event>();
        for (Event event : newEvents) {
            Event oldEvent = oldEventsMap.get(event.Id);
            if (event.EndDateTime != oldEvent.EndDateTime) {
                eventsWithModifiedEndDate.add(event);
            }
        }

        if (eventsWithModifiedEndDate.isEmpty()) {
            return;
        }

        restartLeadSLAWithEvents(eventsWithModifiedEndDate);
    }

    public static void restartLeadSLAWithTasks(List<Task> tasks) {
        if (tasks.isEmpty()) {
            return;
        }

        Map<Id, DateTime> leadIdsWithTasksEndDateTimes = new Map<Id, DateTime>();
        
        for (Task task : tasks) {
            if (task.WhoId != null && task.WhoId.getSObjectType() == Schema.Lead.SObjectType) {
                DateTime taskDateTime = task.ActivityDate != null 
                    ? DateTime.newInstance(task.ActivityDate, Time.newInstance(23, 59, 59, 0))
                    : System.now();

                leadIdsWithTasksEndDateTimes.put(task.WhoId, taskDateTime);
            }
        }

        if (leadIdsWithTasksEndDateTimes.isEmpty()) {
            return;
        }

        System.debug(leadIdsWithTasksEndDateTimes);

        restartLeadSLA(leadIdsWithTasksEndDateTimes);
    }

    public static void restartLeadSLAWithTasks(List<Task> newTasks, Map<Id, Task> oldTasksMap) {
        if (newTasks.isEmpty() || oldTasksMap.isEmpty()) {
            return;
        }

        List<Task> tasksWithModifiedDueDate = new List<Task>();
        for (Task task : newTasks) {
            Task oldTask = oldTasksMap.get(task.Id);
            if (task.ActivityDate != oldTask.ActivityDate) {
                tasksWithModifiedDueDate.add(task);
            }
        }

        if (tasksWithModifiedDueDate.isEmpty()) {
            return;
            }

        restartLeadSLAWithTasks(tasksWithModifiedDueDate);
    }

    private static void restartLeadSLA(Map<Id, DateTime> leadIdsWithEndDateTimes) {
        if (leadIdsWithEndDateTimes.isEmpty()) {
            return;
        }

        List<SLA__c> leadSLAs = SLASelector.getCurrentSLAsByLeadIds(leadIdsWithEndDateTimes.keySet());

        for (SLA__c sla : leadSLAs) {
            sla.DataHoraVencimento__c = leadIdsWithEndDateTimes.get(sla.Lead__c).addMinutes((Integer) sla.TempoLimitePerdaMinutos__c);
        }

        System.debug(leadSLAs);

        update leadSLAs;
    }

    public static SLA__c buildLeadRequiredSLA(Lead lead) {
        if (lead == null || !Schema.SObjectType.Lead.getRecordTypeInfosById().get(lead.RecordTypeId).getDeveloperName().contains('Lead')) {
            return null;
        }

        for (SLAPorFaseDoFunil__c slaRule : SLA_PER_FUNNEL_PHASE) {

            String leadEntrerprise = Schema.SObjectType.Lead.getRecordTypeInfosById().get(lead.RecordTypeId).getDeveloperName().contains('Nortis') ? 'Nortis' : 'Vibra';
            String slaRuleEnterprise = slaRule.RecordType.DeveloperName.contains('Nortis') ? 'Nortis' : 'Vibra';

            if (lead.Status == slaRule.FaseDoFunil__c && leadEntrerprise == slaRuleEnterprise) {
                return new SLA__c(
                    Lead__c = lead.Id,
                    DataHoraVencimento__c = System.now().addMinutes((Integer) slaRule.TempoLimitePerdaMinutos__c),
                    FaseRedirecionamento__c = slaRule.FaseRedirecionamento__c,
                    FilaRedirecionamento__c = slaRule.FilaRedirecionamento__c,
                    TempoLimitePerdaMinutos__c = slaRule.TempoLimitePerdaMinutos__c,
                    FaseDoFunil__c = slaRule.FaseDoFunil__c,
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
                OwnerId = getLeadQueueByDeveloperName(sla.FilaRedirecionamento__c).Id
            ));

            sla.Executado__c = true;
        }

        update dueSLAs;
        update leadsToUpdate;
    }

    private static Group getLeadQueueByDeveloperName(String name) {
        for (Group queue : LEAD_QUEUES) {
            if (queue.DeveloperName == name) {
                return queue;
            }
        }

        return null;
    }
}