trigger LeadTrigger on Lead (after insert, after update) { 
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadTriggerHandler.handleBeforeUpdate(Trigger.new);
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