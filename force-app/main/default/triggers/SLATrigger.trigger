trigger SLATrigger on SLA__c (after insert) {
    new SLATriggerHandler().run();
}