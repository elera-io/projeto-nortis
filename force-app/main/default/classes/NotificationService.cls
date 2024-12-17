public without sharing class NotificationService {

    public static void sendCustomNotification(SObject target, CustomNotificationType notificationType, String title, String body, Set<String> recipientIds) {
        try {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(target.Id);

            notification.send(recipientIds);
        } catch (Exception e) {
            System.debug('Erro ao enviar notificação: ' + e.getMessage());
        }
    }
}