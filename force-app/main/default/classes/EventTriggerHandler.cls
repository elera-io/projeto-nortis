public without sharing class EventTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        
        SLAService.restartLeadSLAWithEvents(Trigger.new);
    }

    public override void afterUpdate() {

        SLAService.restartLeadSLAWithEvents(Trigger.new, (Map<Id, Event>) Trigger.oldMap);
    }

}