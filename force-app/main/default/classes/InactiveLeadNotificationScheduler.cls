public class InactiveLeadNotificationScheduler implements Schedulable {

    public static Integer DAYS_OF_INACTIVITY = 5;
    public static Integer DAYS_SINCE_AWAITING_LAUNCH = 15;
    
    public void execute(SchedulableContext sc) {
        List<Lead> inactiveLeads = [SELECT Id, Name FROM Lead WHERE LastModifiedDate <= :System.now().addDays(-DAYS_OF_INACTIVITY) AND isConverted = false];
            
        if (!inactiveLeads.isEmpty()) {
            SLANotificationService.sendInactiveLeadNotifications(inactiveLeads);
        }

        List<Lead> awaitingLeads = [SELECT 
                Id, Name 
            FROM Lead 
            WHERE 
                Status = 'Pesquisa' 
                AND Subfase__c = 'Aguardando Lançamento'
                AND LastViewedDate <= :System.now().addDays(-DAYS_SINCE_AWAITING_LAUNCH)
        ];

        if (!awaitingLeads.isEmpty()) {
            SLANotificationService.sendAwaitingLeadNotifications(awaitingLeads);
        }
    }

}