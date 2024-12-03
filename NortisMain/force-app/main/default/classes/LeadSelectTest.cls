@isTest
private class LeadSelectTest {

    @TestSetup
    private static void setup() {
        // Criando Leads de exemplo
        Lead testLead1 = new Lead(FirstName = 'John', LastName = 'TestLead1', Email = 'john@example.com', MobilePhone = '1234567890', Status = 'Scheduled');
        Lead testLead2 = new Lead(FirstName = 'Jane', LastName = 'TestLead2', Email = 'jane@example.com', MobilePhone = '0987654321', Status = 'Open');
        insert new List<Lead>{testLead1, testLead2};
    }

    @IsTest
    private static void getLeadsByIdTest() {
        // Testando consulta por ID
        Test.startTest();
        List<Lead> result = LeadSelect.getLeadsById(new Set<String>{'Id'}, new Set<Id>{[SELECT Id FROM Lead LIMIT 1][0].Id});
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Deveria retornar 1 registro');
    }

    @IsTest
    private static void getLeadsByIdWithEmptyFieldsTest() {
        // Testando consulta por ID com campos vazios
        try {
            LeadSelect.getLeadsById(new Set<String>(), new Set<Id>{[SELECT Id FROM Lead LIMIT 1][0].Id});
            System.assert(false, 'Deveria lançar exceção por campos vazios');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Nenhum campo foi fornecido para a consulta.', e.getMessage(), 'Deve lançar exceção com a mensagem correta');
        }
    }

    @IsTest
    private static void getLeadsByIdWithEmptyLeadsIdTest() {
        // Testando consulta por ID com conjunto de IDs vazio
        try {
            LeadSelect.getLeadsById(new Set<String>{'Id'}, new Set<Id>());
            System.assert(false, 'Deveria lançar exceção por IDs vazios');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Nenhum ID de Lead fornecido para a consulta.', e.getMessage(), 'Deve lançar exceção com a mensagem correta');
        }
    }

    @IsTest
    private static void getLeadsByEmailNotIdTest() {
        // Testando consulta por e-mail e ID com registros excluídos
        Id leadId = [SELECT Id FROM Lead WHERE Email = 'john@example.com'][0].Id;
        
        Test.startTest();
        List<Lead> result = LeadSelect.getLeadsByEmailNotId(new Set<String>{'Id', 'Email'}, new Set<String>{'john@example.com', 'jane@example.com'}, new Set<Id>{leadId});
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Deveria retornar 1 lead (jane@example.com), já que john@example.com foi excluído pela condição de Id');
    }

    @IsTest
    private static void getLeadsByEmailNotIdWithEmptyEmailTest() {
        // Testando consulta por e-mail com conjunto de e-mails vazio
        Set<Id> leadIds = new Set<Id>{[SELECT Id FROM Lead LIMIT 1][0].Id};
        Test.startTest();
        List<Lead> result = LeadSelect.getLeadsByEmailNotId(new Set<String>{'Id', 'Email'}, new Set<String>(), leadIds);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Não deve retornar leads com e-mails vazios');
    }

    @IsTest
    private static void updateLeadsTest() {
        // Testando atualização de leads
        Lead leadToUpdate = [SELECT Id, FirstName FROM Lead WHERE FirstName = 'John'][0];
        leadToUpdate.FirstName = 'John Updated';
        
        Test.startTest();
        LeadSelect.updateLeads(new List<Lead>{leadToUpdate});
        Test.stopTest();

        Lead updatedLead = [SELECT FirstName FROM Lead WHERE Id = :leadToUpdate.Id];
        System.assertEquals('John Updated', updatedLead.FirstName, 'O nome do lead deveria ter sido atualizado para "John Updated"');
    }

    @IsTest
    private static void updateLeadsWithEmptyListTest() {
        // Testando atualização com lista vazia
        Test.startTest();
        LeadSelect.updateLeads(new List<Lead>());
        Test.stopTest();

        // Verifica se a execução foi bem-sucedida e nenhuma atualização foi feita
        System.assert(true, 'O método updateLeads não falhou com lista vazia');
    }

    @IsTest
    private static void updateLeadTest() {
        // Testando atualização de um único lead
        Lead leadToUpdate = [SELECT Id, LastName FROM Lead WHERE LastName = 'TestLead1'][0];
        leadToUpdate.LastName = 'UpdatedLastName';
        
        Test.startTest();
        LeadSelect.updateLead(leadToUpdate);
        Test.stopTest();

        Lead updatedLead = [SELECT LastName FROM Lead WHERE Id = :leadToUpdate.Id];
        System.assertEquals('UpdatedLastName', updatedLead.LastName, 'O sobrenome do lead deveria ter sido atualizado para "UpdatedLastName"');
    }

    @IsTest
    private static void updateLeadWithNullLeadTest() {
        // Testando atualização com lead nulo
        Test.startTest();
        LeadSelect.updateLead(null);
        Test.stopTest();

        // Verifica se a execução foi bem-sucedida e nenhuma atualização foi feita
        System.assert(true, 'O método updateLead não falhou com lead nulo');
    }

    @IsTest
    private static void deleteLeadsTest() {
        // Testando exclusão de leads
        List<Lead> leadsToDelete = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        LeadSelect.deleteLeads(leadsToDelete);
        Test.stopTest();

        Integer leadCount = [SELECT count() FROM Lead WHERE Id IN :leadsToDelete];
        System.assertEquals(0, leadCount, 'O lead deveria ter sido excluído');
    }

    @IsTest
    private static void deleteLeadsWithEmptyListTest() {
        // Testando exclusão com lista vazia
        Test.startTest();
        LeadSelect.deleteLeads(new List<Lead>());
        Test.stopTest();

        // Verifica se a execução foi bem-sucedida e nenhuma exclusão foi feita
        System.assert(true, 'O método deleteLeads não falhou com lista vazia');
    }

    @IsTest
    private static void deleteLeadsWithNullTest() {
        // Testando exclusão com null
        Test.startTest();
        LeadSelect.deleteLeads(null);
        Test.stopTest();

        // Verifica se a execução foi bem-sucedida e nenhuma exclusão foi feita
        System.assert(true, 'O método deleteLeads não falhou com null');
    }

    @IsTest
    private static void getLeadScheduledByIdTest() {
        // Testando o método getLeadScheduledById com status Scheduled
        Set<Id> leadIds = new Set<Id>{[SELECT Id FROM Lead WHERE Status = 'Scheduled' LIMIT 1][0].Id};
        Set<String> fields = new Set<String>{'Id', 'FirstName', 'Email'};

        Test.startTest();
        List<Lead> result = LeadSelect.getLeadScheduledById(fields, leadIds);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Deveria retornar 1 lead com status "Scheduled"');
    }

    @IsTest
    private static void getLeadScheduledByIdWithEmptyIdsTest() {
        // Testando consulta com IDs vazios
        Set<Id> leadIds = new Set<Id>();
        Set<String> fields = new Set<String>{'Id', 'FirstName'};

        Test.startTest();
        List<Lead> result = LeadSelect.getLeadScheduledById(fields, leadIds);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Deveria retornar 0 leads quando o conjunto de IDs está vazio');
    }
}
