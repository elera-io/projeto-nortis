trigger LeadTrigger on Lead (after insert, after update, before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.handleAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}