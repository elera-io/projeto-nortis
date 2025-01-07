@isTest
public class NotificationServiceTest {
    @isTest
    static void testSendCustomNotification_Success() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        Set<String> recipientIds = new Set<String>{UserInfo.getUserId()};

        Test.startTest();
        NotificationService.sendCustomNotification(
            testAccount, 
            notificationType, 
            'Teste de Notificação', 
            'Corpo da notificação de teste.', 
            recipientIds
        );
        Test.stopTest();
    }

    @isTest
    static void testSendCustomNotification_ExceptionHandling() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        CustomNotificationType notificationType = new CustomNotificationType();
        Set<String> recipientIds = new Set<String>{};

        Test.startTest();
        NotificationService.sendCustomNotification(
            testAccount, 
            notificationType, 
            'Teste de Erro', 
            'Este é um teste de erro.', 
            recipientIds
        );
        Test.stopTest();
    }
}