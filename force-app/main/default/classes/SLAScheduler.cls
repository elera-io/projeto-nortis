public without sharing class SLAScheduler implements Queueable {

    public void execute(QueueableContext qc) {
        System.enqueueJob(new SLAScheduler(), 5);
        
        SLAService.handleLeadSLAs();
    }
}