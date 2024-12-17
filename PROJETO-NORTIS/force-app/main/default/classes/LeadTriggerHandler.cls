public class LeadTriggerHandler {

    public static void handleBeforeInsert(List<Lead> leads) {
        // Adicione a lógica específica para o evento 'before insert' aqui, se necessário
    }

    public static void handleBeforeUpdate(List<Lead> leads, Map<Id, Lead> oldLeadMap) {
        // Adicione a lógica específica para o evento 'before update' aqui, se necessário

        // Atualiza o campo SDRProprietario__c
        LeadShareManager.updateSDROwnerField(Leads, oldLeadMap);
    }
    
	public static void handleAfterInsert(List<Lead> newLeads) { 
        SLAService.createLeadSLAs(newLeads);
        
        List<Lead> credenciamentoLeads = new List<Lead>();
        List<Lead> leadsWithCampaignAssignment = new List<Lead>();
    
        // Cria um mapa para armazenar o DeveloperName do RecordType para cada Lead
        Map<Id, String> leadIdToRecordTypeMap = new Map<Id, String>();
    
        // Consulta o DeveloperName do RecordType para cada Lead inserido
        List<Lead> leadsWithRecordType = [
            SELECT Id, RecordType.DeveloperName, Campanha__c, DescricaoTipoDeRegistro__c
            FROM Lead 
            WHERE Id IN :newLeads
        ];
    
        for (Lead lead : leadsWithRecordType) {
            leadIdToRecordTypeMap.put(lead.Id, lead.RecordType.DeveloperName);
        }
    
        // Filtra leads por tipo de registro e distribui conforme a lógica de negócio
        for (Lead lead : newLeads) {
            String developerName = leadIdToRecordTypeMap.get(lead.Id);
    
            // Leads de credenciamento
            if (developerName == 'ParceiroVibra' || 
                developerName == 'ParceiroNortis' || 
                developerName == 'ImobiliariaVibra' || 
                developerName == 'ImobiliariaNortis' ||
                developerName == 'CorretorAssociadoNortis' || 
                developerName == 'CorretorAssociadoVibra') {
                credenciamentoLeads.add(lead);
            }
    
            // Leads válidos para vinculação de campanhas
            if ((developerName == 'LeadNortis' || developerName == 'LeadVibra') && !String.isBlank(lead.Campanha__c)) {
                leadsWithCampaignAssignment.add(lead);
                //DistribuirLeadsService.distribuirLeads((List<Lead>)Trigger.new);
            }
        }
    
        // Processa leads de credenciamento
        if (!credenciamentoLeads.isEmpty()) {
            LeadCredenciamentoHandler.processCredenciamentoLeads(credenciamentoLeads);
        }
    
        // Processa leads com atribuição de campanhas
        if (!leadsWithCampaignAssignment.isEmpty()) {
            CampaignService.handleCampaignAssignment(leadsWithCampaignAssignment);
        }
    
        // Lida com iterações específicas de leads
        LeadReiterationHelper.handleReiteration(newLeads);
    }


    
    public static void handleAfterUpdate(List<Lead> updatedLeads, Map<Id, Lead> oldLeadMap) {
        SLAService.updateLeadSLAs(updatedLeads, oldLeadMap);

        List<Lead> leadsWithDocumentationIssues = new List<Lead>();
         List<Lead> leadsToUpdate = new List<Lead>();

        for (Lead lead : updatedLeads) {
            Lead oldLead = oldLeadMap.get(lead.Id);

            // Verifica se o campo Motivo__c foi atualizado para "Problemas de Documentação"
            if (lead.Motivo__c == 'Problemas de Documentação') {
                leadsWithDocumentationIssues.add(lead);
            }
            
			// Verifica se o status mudou para "Visita"
            if (lead.Status == 'Visita' && oldLead.Status != 'Visita' && lead.Subfase__c == '') {
                Lead leadToUpdate = new Lead(Id = lead.Id);
                leadToUpdate.Subfase__c = 'Aguardando Agendamento de Visita';
                leadsToUpdate.add(leadToUpdate);
            }
            
        }
        
        // Chama o método para enviar os e-mails
        if (!leadsWithDocumentationIssues.isEmpty()) {
            LeadDocumentationIssueNotifier.notifyDocumentationIssues(leadsWithDocumentationIssues);
        }

         // Atualiza os registros se necessário
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
        // Gerencia o compartilhamento do Lead
        LeadShareManager.manageLeadSharing(updatedLeads, oldLeadMap);
        
    }
}