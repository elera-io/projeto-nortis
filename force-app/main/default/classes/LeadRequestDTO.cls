global class LeadRequestDTO {

	global String nome;  // Obrigatório
	global String telefone; // Obrigatório
	global String email; // Obrigatório
	global String empreendimento_interesse;
	global String midiaOrigem;
	global String origemMidia; // Duplicado?
	global String canal;
	global String campanha;
	global String conjuntoDeAnuncio;
	global String anuncio;
	global String resumo_lead;
	global List<TrascricaoDialogoDTO> transcricao_dialogo;

    public static String getValidationErrorMessage(LeadRequestDTO request) {
        if (String.isBlank(request.nome) || String.isBlank(request.telefone) || String.isBlank(request.email)) {
            return 'Verifique se todos os campos obrigatórios estão preenchidos: nome, telefone, email';

        } else if (!String.isBlank(request.empreendimento_interesse) && [SELECT COUNT() FROM Empreendimento__c WHERE CodigoSistemaExterno__c = :request.empreendimento_interesse] == 0) {
            return 'Não foi encontrado um Empreendimento representado pelo código externo: ' + request.empreendimento_interesse;

        } else if (!String.isBlank(request.canal)) {
            List<Schema.PicklistEntry> canalPicklistValues = Lead.Canal__c.getDescribe().getPicklistValues();
            
            Boolean isCanalValid = false;

            for (PicklistEntry entry : canalPicklistValues) {
                if (entry.getValue() == request.canal) {
                    isCanalValid = true;
                }
            }
            
            if (!isCanalValid) {
                return 'Valor inválido para o campo canal: ' + request.canal;
            }

        }

        return null;
    }

	public static LeadRequestDTO parse(String json){
		return (LeadRequestDTO) System.JSON.deserialize(json, LeadRequestDTO.class);
	}

    public Lead toLead() {
        Lead lead = new Lead();

        List<String> fullNameSplit = this.nome.normalizeSpace().split(' ');

        if (fullNameSplit.size() > 1) {
            lead.FirstName = fullNameSplit.get(0);

            fullNameSplit.remove(0); // Somente Sobrenomes
            lead.LastName = String.join(fullNameSplit, ' ');
        } else {
            lead.LastName = fullNameSplit.get(0);
        }

        lead.Phone = this.telefone;
        lead.Email = this.email;
        lead.MidiaOrigem__c = this.midiaOrigem;
        lead.Canal__c = this.canal;
        lead.Campanha__c = this.campanha;
        lead.ConjuntoDeAnuncio__c = this.conjuntoDeAnuncio;
        lead.Anuncio__c = this.anuncio;
        lead.ResumoDoLead__c = this.resumo_lead;
        
        if (!String.isBlank(this.empreendimento_interesse)) {
            lead.EmpreendimentoDeInteresse__r = new Empreendimento__c(
                CodigoSistemaExterno__c = this.empreendimento_interesse
            );
        }

        return lead;
    }

    global class TrascricaoDialogoDTO {
		public String mensagem;
		public String origem;
		public Datetime horario;
	}
}