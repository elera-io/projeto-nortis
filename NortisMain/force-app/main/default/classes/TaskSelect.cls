public with sharing class TaskSelect {
    public static List<Task> getCompletedContactTasksByWhoId(Set<String> fields, Set<Id> idLeads){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads AND Status = \'Completed\' AND (Subject = \'Call\' OR Subject = \'E-mail\' OR Subject = \'WhatsApp\')',
                new String[]{String.join(new List<String>(fields), ',')}
             )
        );
    }

    public static List<Task> getTasksByWhoId(Set<String> fields, Set<Id> idLeads){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads ',
                new String[]{String.join(new List<String>(fields), ',')}
             )
        );
    }

    public static List<Task> getTasksReiteracaoNaoIniciadoByWhoId(Set<String> fields, Set<Id> idLeads){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads AND (Subject = \'Reiteração\') AND (Status = \'Não Iniciado\') ',
                new String[]{String.join(new List<String>(fields), ',')}
            )
        );
    }

    public static List<Task> getTasksReiteracaoByWhoId(Set<String> fields, Set<Id> idLeads){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads AND (Subject = \'Reiteração\')',
                new String[]{String.join(new List<String>(fields), ',')}
            )
        );
    }
}