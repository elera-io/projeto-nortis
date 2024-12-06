public with sharing class SLATriggerHandler extends TriggerHandler {
    public override void afterInsert() {

        SLAService.assignNewSLAsToLead(Trigger.new);
    }
}