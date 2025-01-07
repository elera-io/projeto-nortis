@IsTest
public class TaskSelectTest {
    @TestSetup
    static void setup() {
        Lead lead = new Lead(
        FirstName = 'Teeste',
        LastName = 'Teste',
        Description = 'Teste',
        Status = 'Novo',
        Email = 'teste@exemplo.com'  
    );
    insert lead;

        Task task = new Task(
            Subject = 'Call',
            WhoId = lead.Id,
            Status = 'Completed'
        );
        insert task;

        Task task2 = new Task(
            Subject = 'Call',
            WhoId = lead.Id,
            Status = 'In Progress'
        );
        insert task2;

        Task task3 = new Task(
            Subject = 'Reiteração',
            WhoId = lead.Id,
            Status = 'Não Iniciado'
        );
        insert task3;
    }

    @isTest
    static void testGetCompletedContactTasksByWhoId() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Set<Id> idLeads = new Set<Id>();
        idLeads.add(lead.Id);

        Test.startTest();
        List<Task> lstTask = TaskSelect.getCompletedContactTasksByWhoId(new Set<String>{'Id', 'WhoId', 'Status', 'Subject'}, idLeads);
        Test.stopTest();

        System.assertEquals(1, lstTask.size(), 'Deveria haver exatamente uma task completada para o lead.');
        System.assertEquals('Completed', lstTask[0].Status, 'O status da task deveria ser "Completed".');
        System.assertEquals(lead.Id, lstTask[0].WhoId, 'WhoId da task deveria ser igual ao Id do lead.');
    }

    @isTest
    static void testGetTasksByWhoId() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Set<Id> idLeads = new Set<Id>();
        idLeads.add(lead.Id);

        Test.startTest();
        List<Task> lstTask = TaskSelect.getTasksByWhoId(new Set<String>{'Id', 'WhoId', 'Status', 'Subject'}, idLeads);
        Test.stopTest();

    }

    @isTest
    static void testGetTasksReiteracaoNaoIniciadoByWhoId() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Set<Id> idLeads = new Set<Id>();
        idLeads.add(lead.Id);

        Test.startTest();
        List<Task> lstTask = TaskSelect.getTasksReiteracaoNaoIniciadoByWhoId(new Set<String>{'Id', 'WhoId', 'Status', 'Subject'}, idLeads);
        Test.stopTest();

        System.assertEquals(1, lstTask.size(), 'Deveria haver exatamente uma task de reiteração não iniciada para o lead.');
        System.assertEquals('Reiteração', lstTask[0].Subject, 'O assunto da task deveria ser "Reiteração".');
        System.assertEquals('Não Iniciado', lstTask[0].Status, 'O status da task deveria ser "Não Iniciado".');
        System.assertEquals(lead.Id, lstTask[0].WhoId, 'WhoId da task deveria ser igual ao Id do lead.');
    }

    @isTest
    static void testGetTasksReiteracaoByWhoId() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Set<Id> idLeads = new Set<Id>();
        idLeads.add(lead.Id);

        Test.startTest();
        List<Task> lstTask = TaskSelect.getTasksReiteracaoByWhoId(new Set<String>{'Id', 'WhoId', 'Subject', 'Status'}, idLeads);
        Test.stopTest();

        System.assertEquals(1, lstTask.size(), 'Deveria haver exatamente uma task de reiteração para o lead.');
        System.assertEquals('Reiteração', lstTask[0].Subject, 'O assunto da task deveria ser "Reiteração".');
        System.assertEquals(lead.Id, lstTask[0].WhoId, 'WhoId da task deveria ser igual ao Id do lead.');
    }
}