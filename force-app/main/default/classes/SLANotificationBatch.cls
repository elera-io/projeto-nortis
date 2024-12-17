public class SLANotificationBatch implements Database.Batchable<SObject> {

    private static final Integer DELAY_MINUTES = 1;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, FarolDoLeadTexto__c, DataHoraVencimento__c, TempoLimitePerdaMinutos__c, TempoRestanteMinutos__c,
                Lead__r.OwnerId, Lead__r.Name, SLA__c.NotificacaoAmarelaEnviada__c, SLA__c.NotificacaoVermelhaEnviada__c
            FROM SLA__c
            WHERE Lead__c != null
                AND (
                    (FarolDoLeadTexto__c = 'Amarelo' AND NotificacaoAmarelaEnviada__c = false)
                    OR 
                    (FarolDoLeadTexto__c = 'Vermelho' AND NotificacaoVermelhaEnviada__c = false)
                )
                AND Lead__r.Owner.Type IN ('User')
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> warningLeadSLAs) {

        try {
            SLANotificationService.sendSLANotifications((List<SLA__c>) warningLeadSLAs);
        } catch (Exception e) {
            System.debug('Um erro ocorreu durante o envio de notificações de SLA (' + e.getTypeName() + '): ' + e.getMessage() + ' (' + e.getStackTraceString() + ')');
        }
    }

    public void finish(Database.BatchableContext bc) {
        
        System.scheduleBatch(new SLANotificationBatch(), 'SLANotificationBatch', DELAY_MINUTES);
    }

}