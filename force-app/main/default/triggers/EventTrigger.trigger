trigger EventTrigger on Event (after insert, after update) {
    new EventTriggerHandler().run();
}