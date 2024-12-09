@isTest
public class LeadReiterationHelperTest {

    @testSetup
    static void setupTestData() {
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do sistema' AND IsActive = true LIMIT 1];
        Id queueId;
    
        System.runAs(adminUser) {
            
           Group queue = [SELECT Id FROM Group WHERE (DeveloperName = 'SDRVibra' OR DeveloperName = 'SDRNortis') AND Type = 'Queue' LIMIT 1];

            queueId = queue.Id;
    
            
            QueueSObject qso = new QueueSObject(
                QueueId = queueId,
                SObjectType = 'Lead'
            );
            insert qso;
        }
    
    
        List<Empreendimento__c> empreendimentos = new List<Empreendimento__c>();
        for (Integer i = 0; i < 3; i++) {
            empreendimentos.add(new Empreendimento__c(Name = 'Empreendimento ' + i));
        }
        insert empreendimentos;
    
    
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            leads.add(new Lead(
                FirstName = 'Lead ' + i,
                LastName = 'Teste',
                Company = 'Empresa ' + i,
                Canal__c = 'Whatsapp',
                MidiaAtual__c = 'Google',
                EmpreendimentoDeInteresse__c = empreendimentos[0].Id,
                MidiaOrigem__c = 'Google',
                Email = 'email' + i + '@teste.com',
                LeadSource = 'Web',
                OwnerId = queueId
            ));
        }
        insert leads;
    
        List<Task> tasks = new List<Task>();
        for (Lead lead : leads) {
            tasks.add(new Task(
                WhoId = lead.Id,
                Subject = 'Reiteração',
                Status = 'Não Iniciado'
            ));
        }
        insert tasks;
    }

    @isTest
    static void testHandleReiteration() {
        
        Id queueId = [SELECT Id FROM Group WHERE (DeveloperName = 'SDRVibra' OR DeveloperName = 'SDRNortis') AND Type = 'Queue' LIMIT 1].Id;
        
        List<Empreendimento__c> empreendimentos = [SELECT Id FROM Empreendimento__c LIMIT 1];
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            leads.add(new Lead(
                FirstName = 'Lead ' + i,
                LastName = 'Teste',
                Company = 'Empresa ' + i,
                Canal__c = 'Whatsapp',
                MidiaAtual__c = 'Google',
                EmpreendimentoDeInteresse__c = empreendimentos[0].Id,
                MidiaOrigem__c = 'Google',
                Email = 'email' + i + '@teste.com',
                LeadSource = 'Web',
                OwnerId = queueId
            ));
        }
        insert leads;
        
        
        Test.startTest();
        LeadReiterationHelper.handleReiteration(leads);
        Test.stopTest();
        
        Lead updatedLead = [SELECT DataUltimaReiteracao__c, QuantidadeDeReiteracoes__c, LeadSource FROM Lead WHERE Id = :leads[0].Id];
        System.assertNotEquals(0, updatedLead.QuantidadeDeReiteracoes__c, 'QuantidadeDeReiteracoes__c não deve ser 0');
    }

    @isTest
    static void testeHandleTask() {
        List<Lead> baseLeads = [SELECT Id, FirstName, LastName, Company, Email, LeadSource, 
                                MidiaOrigem__c, Canal__c, EmpreendimentoDeInteresse__c, MidiaAtual__c, 
                                QuantidadeDeReiteracoes__c, OwnerId FROM Lead WHERE FirstName LIKE 'Lead' LIMIT 3];
        Map<Id, Lead> mapBaseLeads = new Map<Id, Lead>();
        Map<Id, Lead> newLeads = new Map<Id, Lead>();

        for (Lead baseLead : baseLeads) {
            mapBaseLeads.put(baseLead.Id, baseLead);

            Lead newLead = baseLead.clone(false, true, true, true);
            newLead.Email = baseLead.Email;
            newLead.LeadSource = baseLead.LeadSource;
            newLead.MidiaOrigem__c = baseLead.MidiaOrigem__c;
            newLead.EmpreendimentoDeInteresse__c = baseLead.EmpreendimentoDeInteresse__c;
            newLead.MidiaAtual__c = baseLead.MidiaAtual__c;
            newLead.Canal__c = baseLead.Canal__c;
            newLead.OwnerId = baseLead.OwnerId;
            newLead.QuantidadeDeReiteracoes__c = baseLead.QuantidadeDeReiteracoes__c;
            insert newLead;

            newLeads.put(newLead.Id, newLead);
        }

        Test.startTest();
        LeadReiterationHelper.handleReiterationTasks(newLeads, mapBaseLeads);
        Test.stopTest();

     
        for (Lead lead : newLeads.values()) {
            Lead updatedLead = [SELECT QuantidadeDeReiteracoes__c FROM Lead WHERE Id = :lead.Id];
            System.assertEquals(lead.QuantidadeDeReiteracoes__c, updatedLead.QuantidadeDeReiteracoes__c, 'A quantidade de reiterações deve ser igual');
        }
    }
    
    @isTest
    static void testeHandleTask2() {
        List<Lead> baseLeads = [SELECT Id, FirstName, LastName, Company, Email, LeadSource, 
                                MidiaOrigem__c, Canal__c, EmpreendimentoDeInteresse__c, MidiaAtual__c, 
                                QuantidadeDeReiteracoes__c, OwnerId FROM Lead LIMIT 3];

        Map<Id, Lead> mapBaseLeads = new Map<Id, Lead>();
        Map<Id, Lead> newLeads = new Map<Id, Lead>();

        for (Lead baseLead : baseLeads) {
            mapBaseLeads.put(baseLead.Id, baseLead);

            Lead newLead = baseLead.clone(false, true, true, true);
            newLead.Email = baseLead.Email;
            newLead.LeadSource = baseLead.LeadSource;
            newLead.MidiaOrigem__c = baseLead.MidiaOrigem__c;
            newLead.EmpreendimentoDeInteresse__c = baseLead.EmpreendimentoDeInteresse__c;
            newLead.MidiaAtual__c = baseLead.MidiaAtual__c;
            newLead.Canal__c = baseLead.Canal__c;
            newLead.OwnerId = [SELECT Id FROM Group WHERE (DeveloperName = 'SDRVibra' OR DeveloperName = 'SDRNortis') AND Type = 'Queue' LIMIT 1].id;
            newLead.QuantidadeDeReiteracoes__c = baseLead.QuantidadeDeReiteracoes__c;
            insert newLead;

            newLeads.put(newLead.Id, newLead);
        }

        Test.startTest();
        LeadReiterationHelper.handleReiterationTasks(newLeads, mapBaseLeads);
        Test.stopTest();
    }

    @isTest
    static void testeGetReiteracaoTaskMap() {
        List<Lead> leads = [SELECT Id FROM Lead WHERE FirstName LIKE 'Lead%' LIMIT 3];
        System.debug('lista de leads'+ leads);
        Set<Id> leadIds = new Map<Id, Lead>([SELECT Id FROM Lead WHERE FirstName LIKE 'Lead%' LIMIT 3]).keySet();
        System.debug('id set'+ leadIds);
		List<Task> tasks = new List<Task>();
        for (Lead lead : leads) {
            tasks.add(new Task(
                WhoId = lead.Id,
                Subject = 'Reiteração',
                Status = 'Não Iniciado'
            ));
        }
        insert tasks;
        Test.startTest();
        LeadReiterationHelper.getReiteracaoTaskMap(leadIds);
        Test.stopTest();
    }

    @isTest
    static void testFillRequiredTaskFields() {
        List<Lead> baseLeads = [SELECT Id, FirstName, LastName, Company, Email, LeadSource, MidiaOrigem__c, Canal__c, EmpreendimentoDeInteresse__c, MidiaAtual__c, OwnerId FROM Lead LIMIT 3];  

        Map<Id, Lead> mapBaseLeads = new Map<Id, Lead>();
        Map<Id, Lead> newLeads = new Map<Id, Lead>();

        for (Lead baseLead : baseLeads) {
            mapBaseLeads.put(baseLead.Id, baseLead);

            Lead newLead = baseLead.clone(false, true, true, true);
            newLead.Email = 'novo_' + baseLead.Email;
            newLead.LeadSource = baseLead.LeadSource;
            newLead.MidiaOrigem__c = baseLead.MidiaOrigem__c;
            newLead.EmpreendimentoDeInteresse__c = baseLead.EmpreendimentoDeInteresse__c;
            newLead.MidiaAtual__c = baseLead.MidiaAtual__c;
            newLead.Canal__c = baseLead.Canal__c;
            newLead.OwnerId = baseLead.OwnerId;
            insert newLead;

            newLeads.put(newLead.Id, newLead);
        }

        Test.startTest();
        LeadReiterationHelper.fillRequiredTaskFields(newLeads, mapBaseLeads);
        Test.stopTest();

        for (Lead lead : newLeads.values()) {
            System.assertNotEquals(null, lead.EmpreendimentoDeInteresse__c, 'O EmpreendimentoDeInteresse__c não deve ser nulo');
        }
    }

    @isTest
    static void testSetIterationFields() {
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 2];

        Test.startTest();
        LeadReiterationHelper.setIterationFields(leads);
        Test.stopTest();

        for (Lead lead : [SELECT DataUltimaReiteracao__c, QuantidadeDeReiteracoes__c FROM Lead WHERE Id IN :leads]) {
            System.assertNotEquals(0, lead.QuantidadeDeReiteracoes__c, 'A QuantidadeDeReiteracoes__c não deve ser 0');
        }
    }

    @isTest
    static void testMarkReiteracaoTasksAsCompleted() {
        Set<Id> leadIds = new Map<Id, Lead>([SELECT Id FROM Lead LIMIT 2]).keySet();

        Test.startTest();
        LeadReiterationHelper.markReiteracaoTasksAsCompleted(leadIds);
        Test.stopTest();
        for (Task task : [SELECT Status FROM Task WHERE WhoId IN :leadIds]) {
      		System.assert( task.Status == 'Concluido' || task.Status == 'Completed', 'O status da tarefa deve ser "Concluido" ou "Completed"' );
        }
    }

       @isTest
    static void testIncrementReiterationCounter() {
        Set<Id> leadIds = new Map<Id, Lead>([SELECT Id FROM Lead LIMIT 2]).keySet();

        Test.startTest();
        LeadReiterationHelper.incrementReiterationCounter(leadIds);
        Test.stopTest();

        for (Lead lead : [SELECT QuantidadeDeReiteracoes__c FROM Lead WHERE Id IN :leadIds]) {
            System.assertNotEquals(0, lead.QuantidadeDeReiteracoes__c, 'A QuantidadeDeReiteracoes__c não deve ser 0');
        }
    }

    @isTest
    static void testFindDuplicateRecords() {
        List<Lead> leads = [SELECT Id, FirstName, Email, LeadSource FROM Lead LIMIT 3];
        leads[0].Email = leads[1].Email;

        Test.startTest();
        Map<Id, Lead> duplicates = LeadReiterationHelper.findDuplicateRecords(leads);
        Test.stopTest();

        System.assertNotEquals(null, duplicates, 'Os registros duplicados não devem ser nulos');
    }

    @isTest
    static void testFilterLeads() {
        Lead lead = [SELECT Id, LeadSource FROM Lead LIMIT 1];  
        Map<Id, Lead> leadMap = new Map<Id, Lead>{lead.Id => lead};

        Test.startTest();
        Map<Id, Lead> filteredLeads = LeadReiterationHelper.filterLeads(leadMap);
        Test.stopTest();

        System.assertNotEquals(null, filteredLeads, 'Os leads filtrados não devem ser nulos');
    }
}