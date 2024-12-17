public class SLABatchExecutor implements Database.Batchable<SObject> {

    private static final Integer DELAY_MINUTES = 1;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, DataHoraVencimento__c, FaseRedirecionamento__c, FilaRedirecionamento__c, 
                Lead__c, TempoLimitePerdaMinutos__c, LimitePercentualAmarelo__c, LimitePercentualVerde__c,
                Lead__r.RecordType.DeveloperName, Objeto__c
            FROM SLA__c
            WHERE DataHoraVencimento__c <= :System.now()
                AND Executado__c = false
                AND Lead__c != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> dueLeadSLAs) {

        System.debug(dueLeadSLAs);

        try {
            SLAService.executeDueLeadSLAs((List<SLA__c>) dueLeadSLAs);
        } catch (Exception e) {
            System.debug('Um erro ocorreu durante o processamento de SLA (' + e.getTypeName() + '): ' + e.getMessage() + ' (' + e.getStackTraceString() + ')');
        }
    }

    public void finish(Database.BatchableContext bc) {
        
        System.scheduleBatch(new SLABatchExecutor(), 'SLABatchExecutor', DELAY_MINUTES);
    }

}