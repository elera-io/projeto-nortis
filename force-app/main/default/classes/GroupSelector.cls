public with sharing class GroupSelector {
    
    public static List<Group> getLeadQueues() {
        return [
            SELECT Id, Name, DeveloperName
            FROM Group
            WHERE Type = 'Queue'
                AND Id IN (
                    SELECT QueueId 
                    FROM QueueSobject 
                    WHERE SobjectType = 'Lead'
                )
        ];
    }

    public static List<Group> getLeadQueues() {
        return [
            SELECT Id, Name, DeveloperName
            FROM Group
            WHERE Type = 'Queue'
                AND Id IN (
                    SELECT QueueId 
                    FROM QueueSobject 
                    WHERE SobjectType = 'Lead'
                )
        ];
    }
}