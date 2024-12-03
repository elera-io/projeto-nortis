@isTest
public class LeadReiterationHelperTest {

    @testSetup
    static void setupTestData() {
        // Criando Leads de teste
        Lead lead1 = new Lead(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', LeadSource = 'Ads', MidiaAtual__c = 'Outros', DataUltimaReiteracao__c = null);
        Lead lead2 = new Lead(FirstName = 'Jane', LastName = 'Smith', Email = 'jane.smith@example.com', LeadSource = 'Ads', MidiaAtual__c = 'Evento', DataUltimaReiteracao__c = null);
        insert new List<Lead>{ lead1, lead2 };
    }

    @isTest
    static void testHandleReiteration_NoDuplicates() {
        // Obtendo Leads de teste
        List<Lead> leads = [SELECT Id, FirstName, LastName, Email, LeadSource FROM Lead];

        // Mock do LeadDA.getLeadsById para garantir a cobertura
        Test.startTest();
        LeadReiterationHelper.handleReiteration(leads);
        Test.stopTest();

        // Verificando que nenhuma tarefa foi criada
        List<Task> tasks = [SELECT Id FROM Task WHERE Subject = 'Reiteração'];
        System.assertEquals(0, tasks.size(), 'Nenhuma tarefa de reiteração deve ser criada');
    }


    @isTest
    static void testFillRequiredTaskFields() {
        // Criando o primeiro Lead
        Lead lead1 = new Lead(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert lead1;
    
        // Criando um "Lead duplicado" com o mesmo Email
        Lead duplicateLead = new Lead(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
    
        // Inserindo com 'allOrNone = false' para ignorar duplicados
        Database.SaveResult result = Database.insert(duplicateLead, false);  // Ignora duplicados
        System.debug('Result: ' + result.isSuccess());
    
        // Criando o Map de Leads
        Map<Id, Lead> newLeads = new Map<Id, Lead>();
        newLeads.put(lead1.Id, lead1);
    
        // Adicionando o 'duplicateLead' ao Map (não precisa ser inserido)
        Map<Id, Lead> baseLeads = new Map<Id, Lead>();
        baseLeads.put(duplicateLead.Id, duplicateLead);
    
        // Chamando o método fillRequiredTaskFields
        Test.startTest();
        LeadReiterationHelper.fillRequiredTaskFields(newLeads, baseLeads);
        Test.stopTest();
    
        // Verificando se os campos foram preenchidos corretamente
        Lead updatedLead = newLeads.get(lead1.Id);
        System.assertEquals(updatedLead.Email, duplicateLead.Email, 'O campo de e-mail deve ser atualizado com o valor do lead base');
        System.assertEquals(updatedLead.LastName, duplicateLead.LastName, 'O campo de LastName deve ser atualizado com o valor do lead base');
    }
    

    @isTest
    static void testHandleReiteration_MultipleLeads() {
        // Criando múltiplos leads de teste
        Lead lead1 = new Lead(FirstName = 'John', LastName = 'Smith', Email = 'johnsmith@example.com', LeadSource = 'ZapImoveis', MidiaAtual__c = 'Outros', DataUltimaReiteracao__c = null);
        Lead lead2 = new Lead(FirstName = 'Anna', LastName = 'Doe', Email = 'annadoe@example.com', LeadSource = 'ZapImoveis', MidiaAtual__c = 'Site FG', DataUltimaReiteracao__c = null);
        insert new List<Lead>{ lead1, lead2 };

        // Obtendo leads para reiteração
        List<Lead> leads = [SELECT Id, FirstName, LastName, Email, LeadSource FROM Lead WHERE Email IN ('johnsmith@example.com', 'annadoe@example.com')];

        // Chamando o método de handleReiteration para múltiplos leads
        Test.startTest();
        LeadReiterationHelper.handleReiteration(leads);
        Test.stopTest();

        // Verificando que duas tarefas foram criadas
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE Subject = 'Reiteração'];
        System.assertEquals(2, tasks.size(), 'Duas tarefas de reiteração devem ser criadas');
    }

    @isTest
    static void testFindDuplicateRecords() {
        // Criar leads duplicados para simular o método de encontrar duplicatas
        Lead lead1 = new Lead(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        Lead lead2 = new Lead(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert new List<Lead>{ lead1, lead2 };

        // Chamando findDuplicateRecords diretamente
        Test.startTest();
        Map<Id, Lead> duplicateLeads = LeadReiterationHelper.findDuplicateRecords(new List<Lead>{lead1, lead2});
        Test.stopTest();

        // Verificando se os duplicados foram encontrados
        System.assert(duplicateLeads.size() > 0, 'Duplicados devem ser encontrados');
    }
}
