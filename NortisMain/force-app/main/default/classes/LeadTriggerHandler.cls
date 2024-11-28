public class LeadTriggerHandler {

    public static void handleBeforeInsert(List<Lead> leads) {
        // Adicione a lógica específica para o evento 'before insert' aqui, se necessário
    }

    public static void handleBeforeUpdate(List<Lead> leads) {
        // Adicione a lógica específica para o evento 'before update' aqui, se necessário
    }
    
    public static void handleAfterInsert(List<Lead> newLeads) {
        List<Lead> credenciamentoLeads = new List<Lead>();

        // Cria um mapa para armazenar o DeveloperName do RecordType para cada Lead
        Map<Id, String> leadIdToRecordTypeMap = new Map<Id, String>();

        // Consulta o DeveloperName do RecordType para cada Lead inserido
        List<Lead> leadsWithRecordType = [SELECT Id, RecordType.DeveloperName FROM Lead WHERE Id IN :newLeads];
        for (Lead lead : leadsWithRecordType) {
            leadIdToRecordTypeMap.put(lead.Id, lead.RecordType.DeveloperName);
        }

        // Filtra apenas os leads de credenciamento usando os valores obtidos na consulta
        for (Lead lead : newLeads) {
            String developerName = leadIdToRecordTypeMap.get(lead.Id);

            if (developerName == 'ParceiroVibra' || 
                developerName == 'ParceiroNortis' || 
                developerName == 'ImobiliariaVibra' || 
                developerName == 'ImobiliariaNortis' ||
                developerName == 'CorretorAssociadoNortis' || 
                developerName == 'CorretorAssociadoVibra') {
                credenciamentoLeads.add(lead);
            }
        }

        // Processa apenas os leads de credenciamento
        if (!credenciamentoLeads.isEmpty()) {
            LeadCredenciamentoHandler.processCredenciamentoLeads(credenciamentoLeads);
        }

        LeadReiterationHelper.handleReiteration(newLeads);
        
        // Aqui tratar lógicas específicas para outros tipos de leads no futuro
    }
    
    public static void handleAfterUpdate(List<Lead> updatedLeads, Map<Id, Lead> oldLeadMap) {
        List<Lead> leadsWithDocumentationIssues = new List<Lead>();

        for (Lead lead : updatedLeads) {
            Lead oldLead = oldLeadMap.get(lead.Id);

            // Verifica se o campo Motivo__c foi atualizado para "Problemas de Documentação"
            if (lead.Motivo__c == 'Problemas de Documentação') {
                leadsWithDocumentationIssues.add(lead);
            }

        }

        // Chama o método para enviar os e-mails
        if (!leadsWithDocumentationIssues.isEmpty()) {
            LeadDocumentationIssueNotifier.notifyDocumentationIssues(leadsWithDocumentationIssues);
        }

    }
}