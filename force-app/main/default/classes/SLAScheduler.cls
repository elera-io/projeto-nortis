public without sharing class SLAScheduler implements Queueable {
    private static final Integer DELAY_MINUTES = 1;

    public void execute(QueueableContext qc) {

        try {
            SLAService.handleLeadSLAs();
        } catch (Exception e) {
            System.debug('Um erro ocorreu durante o processamento da SLA (' + e.getTypeName() + '): ' + e.getMessage() + ' (' + e.getStackTraceString() + ')');
        } finally {
            System.enqueueJob(new SLAScheduler(), DELAY_MINUTES);
        }
    }
}