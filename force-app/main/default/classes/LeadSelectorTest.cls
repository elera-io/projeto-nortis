@isTest
private class LeadSelectorTest {

    @isTest
    private static void testObterLeadsParaDistribuir() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.LastName = 'Teste Lead';
        testLead.Email = 'teste@example.com';
        insert testLead;
        
        List<Lead> leads = LeadSelector.obterLeadsParaDistribuir();
        
        System.assertNotEquals(leads, null);
        System.assert(leads.size() > 0);
        
        Test.stopTest();
    }

    @isTest
    private static void testObterLeadsNaFilaNaoDistribuidos() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.LastName = 'Teste Lead';
        testLead.Email = 'teste@example.com';
        insert testLead;
        
        List<Lead> leads = LeadSelector.obterLeadsNaFilaNaoDistribuidos();
        
        System.assertNotEquals(leads, null);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testObterLeadsEmAtendimento() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.LastName = 'Teste Lead';
        testLead.Email = 'lead@gmail.com';
        insert testLead;
        
        List<Lead> leads = LeadSelector.obterLeadsEmAtendimento();
        
        System.assertNotEquals(leads, null);
       
        Test.stopTest();
    }
    
    @isTest
    private static void testObterLeadsPorIdsProprietarios() {
        Test.startTest();
        
        Lead testLead1 = new Lead();
        testLead1.LastName = 'Teste Lead 1';
        testLead1.Email = 'lead@gmail.com';
        testLead1.OwnerId = UserInfo.getUserId(); // Assume o usuário como proprietário.
        insert testLead1;
        
        Lead testLead2 = new Lead();
        testLead2.LastName = 'Teste Lead 2';
        testLead2.Email = 'lead@gmail.com';
        testLead2.OwnerId = UserInfo.getUserId();
        insert testLead2;
        
        Set<Id> ownerIds = new Set<Id>{UserInfo.getUserId()};
        List<Lead> leads = LeadSelector.obterLeadsPorIdsProprietarios(ownerIds);
        
        System.assertNotEquals(leads, null);
        System.assert(leads.size() > 0);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testObterLeadsPorIdsUsuarios() {
        Test.startTest();
        
        User testUser = [SELECT Id FROM User LIMIT 1]; // Pega um usuário existente.
        
        Lead testLead = new Lead();
        testLead.LastName = 'Teste Lead';
        testLead.Email = 'lead@gmail.com';
        testLead.CorretorDoLead__c = testUser.Id;
        insert testLead;
        
        Set<Id> userIds = new Set<Id>{testUser.Id};
        List<Lead> leads = LeadSelector.obterLeadsPorIdsUsuarios(userIds);
        
        System.assertNotEquals(leads, null);
        System.assert(leads.size() > 0);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testObterPorIdCorretor() {
        Test.startTest();
        
        User testUser = [SELECT Id FROM User LIMIT 1]; // Pega um usuário existente.
        
        Lead testLead = new Lead();
        testLead.LastName = 'Teste Lead';
        testLead.Email = 'lead@gmail.com';
        insert testLead;
        
        Set<Id> userIds = new Set<Id>{testUser.Id};
        List<Lead> leads = LeadSelector.obterPorIdCorretor(userIds);
        
        System.assertNotEquals(leads, null);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testObterPorIdCorretorDoLead() {
        Test.startTest();
        
        User testUser = [SELECT Id FROM User LIMIT 1]; // Pega um usuário existente.
        
        Lead testLead = new Lead();
        testLead.LastName = 'Teste Lead';
        testLead.Email = 'lead@gmail.com';
        testLead.CorretorDoLead__c = testUser.Id;
        insert testLead;
        
        Set<Id> userIds = new Set<Id>{testUser.Id};
        List<Lead> leads = LeadSelector.obterPorIdCorretorDoLead(userIds);
        
        System.assertNotEquals(leads, null);
        System.assert(leads.size() > 0);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testObterLeadsPorIds() {
        Test.startTest();
        
        Lead testLead1 = new Lead();
        testLead1.LastName = 'Teste Lead 1';
        testLead1.Email = 'lead@gmail.com';
        insert testLead1;
        
        Lead testLead2 = new Lead();
        testLead2.LastName = 'Teste Lead 2';
        testLead2.Email = 'lead@gmail.com';
        insert testLead2;
        
        Set<Id> leadIds = new Set<Id>{testLead1.Id, testLead2.Id};
        List<Lead> leads = LeadSelector.obterLeadsPorIds(leadIds);
        
        System.assertNotEquals(leads, null);
        System.assert(leads.size() == 2);
        
        Test.stopTest();
    }

    @isTest
    private static void testObterLeadsPorInformacoesConcierge() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.LastName = 'José Silva';
        testLead.Email = 'jose@example.com';
        testLead.MobilePhone =  '11999999999';
        insert testLead;
        
        LeadSelector.obterLeadsPorInformacoesConcierge('José Silva', '11999999999', 'jose@example.com');
        
        Test.stopTest();
    }
    
 
    @isTest
    private static void testGetLeadScheduledById() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.LastName = 'Scheduled Lead';
        testLead.Email = 'lead@gmail.com';
        testLead.Status = 'Scheduled';
        insert testLead;
        
        Set<String> fields = new Set<String>{'Name', 'Status'};
        Set<Id> leadIds = new Set<Id>{testLead.Id};
        List<Lead> leads = LeadSelector.getLeadScheduledById(fields, leadIds);
        
        System.assertNotEquals(leads, null);
        System.assertEquals(leads.size(), 1);
        
        Test.stopTest();
    }

    @isTest
    private static void testGetLeadsById() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.Email = 'lead@gmail.com';
        testLead.LastName = 'Lead by ID Test';
        insert testLead;
        
        Set<String> fields = new Set<String>{'Name', 'Email'};
        Set<Id> leadIds = new Set<Id>{testLead.Id};
        List<Lead> leads = LeadSelector.getLeadsById(fields, leadIds);
        
        System.assertNotEquals(leads, null);
        System.assertEquals(leads.size(), 1);
        
        Test.stopTest();
    }

    @isTest
    private static void testGetLeadsByEmailNotId() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.LastName = 'Lead by Email Not ID Test';
        testLead.Email = 'lead@example.com';
        insert testLead;
        
        Set<String> fields = new Set<String>{'Name', 'Email'};
        Set<String> leadsEmails = new Set<String>{'lead@example.com'};
        Set<Id> leadIds = new Set<Id>{testLead.Id};
        List<Lead> leads = LeadSelector.getLeadsByEmailNotId(fields, leadsEmails, leadIds);
        
        System.assertNotEquals(leads, null);
        System.assertEquals(leads.size(), 0);  // Nenhum lead idêntico deve estar na lista
        
        Test.stopTest();
    }
    
    @isTest
    private static void testUpdateLeads() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.LastName = 'Lead para atualizar';
        testLead.Email = 'lead@gmail.com';
        insert testLead;
        
        testLead.LastName = 'Lead atualizado';
        LeadSelector.updateLead(testLead);
        
        Lead updatedLead = [SELECT Name FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(updatedLead.Name, 'Lead atualizado');
        
        Test.stopTest();
    }
    
    @isTest
    private static void testDeleteLeads() {
        Test.startTest();
        
        Lead testLead = new Lead();
        testLead.LastName = 'Lead para deletar';
        testLead.Email = 'lead@gmail.com';
        insert testLead;
        
        List<Lead> leads = new List<Lead>{testLead};
        LeadSelector.deleteLeads(leads);
        
        
        Test.stopTest();
    }

    @isTest
    private static void testObterOportunidade() {
        Test.startTest();
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Teste Oportunidade';
        testOpportunity.StageName = 'Qualificação';
        testOpportunity.CloseDate = Date.today();
        insert testOpportunity;
        
        Opportunity fetchedOpportunity = LeadSelector.obterOportunidade(testOpportunity.Id);
        
        System.assertNotEquals(fetchedOpportunity, null);
        System.assertEquals(fetchedOpportunity.Name, 'Teste Oportunidade');
        
        Test.stopTest();
    }
    
    @isTest
    private static void testObterLeadsAgregados() {
        Test.startTest();
        
        User testUser = [SELECT Id FROM User LIMIT 1]; 
        
        Lead testLead = new Lead();
        testLead.LastName = 'Teste Lead';
        testLead.Email = 'lead@gmail.com';
        testLead.CorretorDoLead__c = testUser.Id;
        insert testLead;
        
        List<Id> userIds = new List<Id>{testUser.Id};
        List<AggregateResult> results = LeadSelector.obterLeadsAgregados(userIds);
        
        System.assertNotEquals(results, null);
        System.assert(results.size() > 0);
        
        Test.stopTest();
    }
}