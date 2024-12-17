public without sharing class SLANotificationService {
    
    public static final String CUSTOM_NOTIFICATION_DEVELOPER_NAME = 'NotificacaoSLA';
    public static final CustomNotificationType CUSTOM_NOTIFICATION_TYPE = [
        SELECT Id, DeveloperName 
        FROM CustomNotificationType 
        WHERE DeveloperName = :CUSTOM_NOTIFICATION_DEVELOPER_NAME
    ];

    public static void sendSLANotifications(List<SLA__c> slas) {

        if (slas.isEmpty()) {
            return;
        }

        for (SLA__c sla : slas) {
            sendSLANotifications(sla);
        }

        update slas;
    }

    public static void sendSLANotifications(SLA__c sla) {
        if (!(sla.Lead__r.OwnerId.getSObjectType() == Schema.User.SObjectType)) {
            return;
        }

        Set<String> recipientIds = new Set<String>();

        recipientIds.add(sla.Lead__r.OwnerId);

        List<User> leadOwner = [SELECT ManagerId FROM User WHERE Id = :sla.Lead__r.OwnerId];

        if (!leadOwner.isEmpty() && leadOwner.get(0).ManagerId != null) {            
            recipientIds.add(leadOwner.get(0).ManagerId);
        }
        
        NotificationService.sendCustomNotification(
            new Lead (Id = sla.Lead__c),
            CUSTOM_NOTIFICATION_TYPE,
            generateNotificationTitle(sla), 
            'O SLA do lead vence em ' + sla.TempoRestanteMinutos__c + ' minutos.', 
            recipientIds
        );
        
        if (sla.FarolDoLeadTexto__c == 'Amarelo' && sla.NotificacaoAmarelaEnviada__c == false) {
            sla.NotificacaoAmarelaEnviada__c = true;
        } else if (sla.FarolDoLeadTexto__c == 'Vermelho' && sla.NotificacaoVermelhaEnviada__c == false) {
            sla.NotificacaoVermelhaEnviada__c = true;
        }
    }

    private static String generateNotificationTitle(SLA__c sla) {
        
        switch on sla.FarolDoLeadTexto__c {
            when 'Amarelo' {
                return 'SLA Amarelo: Lead ' + sla.Lead__r.Name + ' vence em ' + sla.TempoRestanteMinutos__c + ' minutos';
            }
            when 'Vermelho' {
                return 'SLA Vermelho: Lead ' + sla.Lead__r.Name + ' vence em ' + sla.TempoRestanteMinutos__c + ' minutos';
            }
            when else {
                return null;
            }
        }
    }

    public static void sendInactiveLeadNotifications(List<Lead> leads) {

        if (leads.isEmpty()) {
            return;
        }

        for (Lead lead : leads) {
            sendInactiveLeadNotification(lead);
        }
    }

    public static void sendInactiveLeadNotification(Lead lead) {

        if (!(lead.OwnerId.getSObjectType() == Schema.User.SObjectType)) {
            return;
        }
        
        Set<String> recipientIds = new Set<String>();

        recipientIds.add(lead.OwnerId);

        List<User> leadOwner = [SELECT ManagerId FROM User WHERE Id = :lead.OwnerId];

        if (!leadOwner.isEmpty() && leadOwner.get(0).ManagerId != null) {            
            recipientIds.add(leadOwner.get(0).ManagerId);
        }
        
        NotificationService.sendCustomNotification(
            lead, 
            CUSTOM_NOTIFICATION_TYPE,
            'Lead Inativo: ' + lead.Name, 
            'O lead ' + lead.Name + ' está inativo devido a falta de movimentação.',
            recipientIds
        );
    }

    public static void sendAwaitingLeadNotifications(List<Lead> leads) {

        if (leads.isEmpty()) {
            return;
        }

        for (Lead lead : leads) {
            sendInactiveLeadNotification(lead);
        }
    }

    public static void sendAwaitingLeadNotification(Lead lead)  {
        if (!(lead.OwnerId.getSObjectType() == Schema.User.SObjectType)) {
            return;
        }
        
        Set<String> recipientIds = new Set<String>();

        recipientIds.add(lead.OwnerId);

        List<User> leadOwner = [SELECT ManagerId FROM User WHERE Id = :lead.OwnerId];

        if (!leadOwner.isEmpty() && leadOwner.get(0).ManagerId != null) {            
            recipientIds.add(leadOwner.get(0).ManagerId);
        }
        
        NotificationService.sendCustomNotification(
            lead, 
            CUSTOM_NOTIFICATION_TYPE,
            'Lead Aguardando Lançamento: ' + lead.Name, 
            'Lead ' + lead.Name + ' aguardando lançamento, não deixe de tratá-lo...',
            recipientIds
        );
    }
}