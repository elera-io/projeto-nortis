public class LeadReiterationHelper {

    private static final Id REITERACAO_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName()
        .get('Reiteração')
        .getRecordTypeId();

    public static void handleReiteration(List<Lead> leads) {
        Map<Id,Lead> reiteratedLeads = findDuplicateRecords(leads);
        if(reiteratedLeads.isEmpty()) { return; }
        Map<Id,Lead> mapBaseLeads = new Map<Id,Lead>(
            LeadSelect.getLeadsById(
                ObjectHelper.getFieldSet('Lead'),
                reiteratedLeads.keySet()
            )
        );
        setIterationFields(reiteratedLeads.values());
        LeadSelect.updateLeads(reiteratedLeads.values());
        handleReiterationTasks(reiteratedLeads, mapBaseLeads);
    }
    
    public static void setIterationFields(List<Lead> leads) {
        for(Lead iLead : leads) {
            iLead.DataUltimaReiteracao__c = Date.today();
        }
    }

    public static void handleReiterationTasks(Map<Id,Lead> newLeads, Map<Id,Lead> mapBaseLeads){
        fillRequiredTaskFields(newLeads, mapBaseLeads);

        markReiteracaoTasksAsCompleted(newLeads.keySet());

        Map<Id, List<Task>> reiterationTaskMap = getReiteracaoTaskMap(newLeads.keySet());
        List<Task> reiterationTasks = new List<Task>();

        for(Lead iLead : newLeads.values()){
            reiterationTasks.add(
                new Task(
                    RecordTypeId = REITERACAO_RECORD_TYPE_ID,
                    WhoId = iLead.Id,
                    OwnerId = iLead.OwnerId,
                    Subject = 'Reiteração',
                    ActivityDate = Date.today().addDays(1),
                    DataHoraInteracao__c = System.now(),
                    EmpreendimentoDeInteresse__c = iLead.EmpreendimentoDeInteresse__c,
                    MidiaAtual__c = iLead.MidiaAtual__c,
                    OrigemLead__c = iLead.MidiaOrigem__c,
                    LeadSource__c = iLead.LeadSource,
                    Canal__c = iLead.Canal__c
                ) 
            );
        }

        insert reiterationTasks;

        incrementReiterationCounter(newLeads.keySet());

    }

    public static void fillRequiredTaskFields(Map<Id,Lead> newLeads, Map<Id,Lead> mapBaseLeads) {
        for (Lead iLead : newLeads.values()) {
            iLead.OwnerId = iLead.OwnerId ?? mapBaseLeads.get(iLead.Id).OwnerId;
            iLead.Email = iLead.Email ?? mapBaseLeads.get(iLead.Id).Email;
            iLead.LastName = iLead.LastName ?? mapBaseLeads.get(iLead.Id).LastName;
            iLead.LeadSource = iLead.LeadSource ?? mapBaseLeads.get(iLead.Id).LeadSource;
            iLead.MidiaOrigem__c = iLead.MidiaOrigem__c ?? mapBaseLeads.get(iLead.Id).MidiaOrigem__c;
            iLead.MidiaAtual__c = iLead.MidiaAtual__c ?? mapBaseLeads.get(iLead.Id).MidiaAtual__c;
            iLead.EmpreendimentoDeInteresse__c = iLead.EmpreendimentoDeInteresse__c ?? mapBaseLeads.get(iLead.Id).EmpreendimentoDeInteresse__c;
            iLead.Canal__c = iLead.Canal__c ?? mapBaseLeads.get(iLead.Id).Canal__c;

        }
    }

    public static Map<Id, List<Task>> getReiteracaoTaskMap(Set<Id> idLeads){
        List<Task> reiterationTasks = TaskSelect.getTasksReiteracaoNaoIniciadoByWhoId(
            new Set<String>{'Id', 'Status', 'WhoId'},
            idLeads
        );
        Map<Id,List<Task>> reiterationTaskMap = new Map<Id, List<Task>>();
        for(Task iTask : reiterationTasks){
            List<Task> taskList = reiterationTaskMap.containsKey(iTask.WhoId)
                ? reiterationTaskMap.get(iTask.WhoId)
                : new List<Task>();
            taskList.add(iTask);
            reiterationTaskMap.put(iTask.WhoId, taskList);
        }
        return reiterationTaskMap;
    }

    public static Map<Id,Lead> findDuplicateRecords(List<Lead> insertedLeads) {
        List<Lead> leadsToDelete = new List<Lead>();
        Map<Id,Lead> leadMap = new Map<Id,Lead>();
        for(Lead iLead : insertedLeads.deepClone(true)){
            List<Datacloud.FindDuplicatesResult> duplicateResults = Datacloud.FindDuplicates.findDuplicates(new List<Lead>{iLead});
            for (Datacloud.FindDuplicatesResult dupeResult : duplicateResults) {
                for (Datacloud.DuplicateResult dupeRes : dupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchRes : dupeRes.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRec : matchRes.getMatchRecords()) {
                            Lead dupe = (Lead) matchRec.getRecord();
                            if(iLead.Id != dupe.Id) {
                                leadsToDelete.add(new Lead(Id = iLead.Id));
                                iLead.Id = dupe.Id;
                                leadMap.put(dupe.Id, iLead);
                            }
                        }
                    }
                }
            }
        }
        LeadSelect.deleteLeads(leadsToDelete);
        return filterLeads(leadMap);
    }

    //Metodo feito para eliminar a edição do campo PrimeiroEmpreendimento__c na reiteração;
    public static Map<Id,Lead> filterLeads(Map<Id,Lead> leadMap) {
        Map<Id,Lead> filteredLeadMap = new Map<Id,Lead>();

        for(Lead iLead : leadMap.values()) {
            Map<String,Object> leadFieldMap = new Map<String, Object>(iLead.getPopulatedFieldsAsMap());
            leadFieldMap.remove('PrimeiroEmpreendimento__c');
            Lead filteredLead = (Lead) JSON.deserialize(JSON.serialize(leadFieldMap), Lead.class);
            filteredLeadMap.put(iLead.Id, filteredLead);
        }

        return filteredLeadMap;
    }

    public static void markReiteracaoTasksAsCompleted(Set<Id> leadIds) {
        List<Task> tasksToUpdate = TaskSelect.getTasksReiteracaoByWhoId(
            new Set<String>{'Id', 'Status'}, 
            leadIds
        );
        
        for (Task task : tasksToUpdate) {
            if (task.Status != 'Completed') {
                task.Status = 'Completed';
            }
        }
    
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }

    public static void incrementReiterationCounter(Set<Id> leadIds) {
        List<Lead> leadsToUpdate = [SELECT Id, QuantidadeDeReiteracoes__c FROM Lead WHERE Id IN :leadIds];

        for (Lead lead : leadsToUpdate) {
            lead.QuantidadeDeReiteracoes__c = (lead.QuantidadeDeReiteracoes__c == null ? 0 : lead.QuantidadeDeReiteracoes__c) + 1;
        }

        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
}