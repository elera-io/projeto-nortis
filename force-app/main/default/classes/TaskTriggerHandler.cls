public without sharing class TaskTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {

        SLAService.restartLeadSLAWithTasks(Trigger.new);
    }

    public override void afterUpdate() {

        SLAService.restartLeadSLAWithTasks(Trigger.new, (Map<Id, Task>) Trigger.oldMap);
    }
}