@isTest
public class SLANotificationServiceTest {

    @testSetup
    static void setupTestData() {
     
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Usuário Padrão' LIMIT 1];
 
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Usuário Nortis e Vibra' LIMIT 1];

        // Group queue = new Group(
        //     Name = 'Fila de Teste',
        //     Type = 'Queue'
            
        // );
        // insert queue;

        // QueueSObject queueSObject = new QueueSObject(
        //     QueueId = queue.Id,
        //     SObjectType = 'Lead'
        // );
        // insert queueSObject;

        User owner = new User(
            FirstName = 'Owner',
            LastName = 'User',
            Username = 'owner.user@test.com',
            Email = 'owner.user@test.com',
            Alias = 'ownerusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = userProfile.Id
        );
        insert owner;

        Lead lead = new Lead(
            LastName = 'Lead de Teste',
            Company = 'Empresa de Teste',
            Email = 'teste@test.com',
            OwnerId = owner.Id
        );
        insert lead;

        // Lead leadQueue = new Lead(
        //     LastName = 'Lead de Teste',
        //     Company = 'Empresa de Teste',
        //     Email = 'teste@test.com',
        //     OwnerId = queue.Id
        // );
        // insert leadQueue;

        SLA__c sla = new SLA__c(
            DataHoraVencimento__c = System.now().addDays(-1),
            Executado__c = false,
            // Lead__c = leadQueue.Id,
            Lead__c = lead.Id,
            LimitePercentualAmarelo__c = 50,
            LimitePercentualVerde__c = 100,
            Objeto__c = 'Lead',
            TempoLimitePerdaMinutos__c = 1440,
            FaseDoFunil__c = 'Novo',
            NotificacaoAmarelaEnviada__c = false,
            NotificacaoVermelhaEnviada__c = false
            // TempoRestanteMinutos__c = 1440
        );
        insert sla;
    }

    @isTest
    static void testSendSLANotifications() {
        SLA__c sla = [SELECT Id, Lead__r.OwnerId, FarolDoLeadTexto__c,TempoRestanteMinutos__c, Lead__r.Name FROM SLA__c LIMIT 1];

        Test.startTest();
        SLANotificationService.sendSLANotifications(new List<SLA__c>{ sla });
        Test.stopTest();

        sla = [SELECT NotificacaoAmarelaEnviada__c FROM SLA__c WHERE Id = :sla.Id];
        // System.assert(sla.NotificacaoAmarelaEnviada__c, true);
    }

    @isTest
    static void testSendSLANotificationsSla() {
        SLA__c sla = [SELECT Id, Lead__r.OwnerId, FarolDoLeadTexto__c,TempoRestanteMinutos__c, Lead__r.Name FROM SLA__c LIMIT 1];

        Test.startTest();
        SLANotificationService.sendSLANotifications(sla);
        Test.stopTest();

        sla = [SELECT NotificacaoAmarelaEnviada__c FROM SLA__c WHERE Id = :sla.Id];
        // System.assert(sla.NotificacaoAmarelaEnviada__c, true);
    }

    @isTest
    static void testSendInactiveLeadNotifications() {
        Lead lead = [SELECT Id, OwnerId, Name FROM Lead LIMIT 1];

        Test.startTest();
        SLANotificationService.sendInactiveLeadNotifications(new List<Lead>{ lead });
        Test.stopTest();

        // Verificar se a notificação foi enviada (log ou mock)
        // Não há persistência direta para verificar, considerar mocks para NotificationService
    }

    @isTest
    static void testSendAwaitingLeadNotifications() {
        Lead lead = [SELECT Id, OwnerId, Name FROM Lead LIMIT 1];

        Test.startTest();
        SLANotificationService.sendAwaitingLeadNotifications(new List<Lead>{ lead });
        Test.stopTest();

        // Verificar se a notificação foi enviada (log ou mock)
        // Não há persistência direta para verificar, considerar mocks para NotificationService
    }

    // @isTest
    // static void testInvalidOwner() {
    //     // Criar um Lead com OwnerId inválido
    //     Lead lead = new Lead(
    //         LastName = 'Lead Sem Usuário',
    //         Company = 'Empresa Sem Usuário',
    //         OwnerId = UserInfo.getUserId(),
    //         Email = 'teste@elega.com.br'
    //     );
    //     insert lead;

    //     // Criar SLA correspondente
    //     SLA__c sla = new SLA__c(
    //         DataHoraVencimento__c = System.now().addDays(-1),
    //         Executado__c = false,
    //         Lead__c = lead.Id,
    //         LimitePercentualAmarelo__c = 50,
    //         LimitePercentualVerde__c = 100,
    //         Objeto__c = 'Lead',
    //         FaseDoFunil__c = 'Novo',
    //         NotificacaoAmarelaEnviada__c = false,
    //         NotificacaoVermelhaEnviada__c = false
    //     );
    //     insert sla;

    //     // Executar método
    //     Test.startTest();
    //     SLANotificationService.sendSLANotifications(new List<SLA__c>{ sla });
    //     Test.stopTest();

    //     // Verificar que nenhuma notificação foi enviada (mock ou logs)
    // }

    @isTest
    static void testSendAwaitingLeadNotification() {
        Lead lead = [SELECT Id, OwnerId, Name FROM Lead LIMIT 1];

        Test.startTest();
        SLANotificationService.sendAwaitingLeadNotification(lead);
        Test.stopTest();

        // Verificar se a notificação foi enviada corretamente
        // Utilize mock ou log para validar se necessário
    }
}