public without sharing class LeadSelect {

    // public static List<Lead> obterLeadsPorInformacoesConcierge(Set<String> fields, String nome, String email, String celular) {
    //     return Database.query(String.format(
    //         'SELECT {0} ' +
    //         'FROM Lead WHERE ' +
    //             '(' +  
    //                 '(Name != null AND Name LIKE \'%' + nome + '%\') OR ' + 
    //                 '(Email != null AND Email LIKE \'%' + email + '%\') OR ' + 
    //                 '(MobilePhone != null AND MobilePhone LIKE \'%' + celular + '%\')' +
    //             ') AND ' +
    //             'IsConverted = false',
    //         new String[]{String.join(new List<String>(fields), ',')}
    //     ));
    // }

    public static List<Lead> getLeadScheduledById(Set<String> fields, Set<Id> leadsId){
        return Database.query(String.format(
            'SELECT {0} FROM Lead WHERE Id IN :leadsId AND (Status = \'Scheduled\')',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }

    public static List<Lead> getLeadsById(Set<String> fields, Set<Id> leadsId){
        List<String> fieldList = new List<String>(fields);

        if (fieldList.isEmpty()) {
            throw new IllegalArgumentException('Nenhum campo foi fornecido para a consulta.');
        }

        String query = 'SELECT ' + String.join(fieldList, ',') + ' FROM Lead WHERE Id IN :leadsId';
        
        if (leadsId == null || leadsId.isEmpty()) {
            throw new IllegalArgumentException('Nenhum ID de Lead fornecido para a consulta.');
        }

        return Database.query(query);
    }
    
    
    
    public static List<Lead> getLeadsByEmailNotId(Set<String> fields, Set<String> leadsEmail, Set<Id> leadsId){
        return Database.query(String.format(
            'SELECT {0} FROM Lead WHERE (Email != null AND Email IN :leadsEmail) AND Id NOT IN :leadsId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }

    public static void updateLeads(List<Lead> leads) {
        if(leads == null || leads.isEmpty()) return;
        update leads;
    }

    public static void updateLead(Lead lead) {
        if(lead == null) return;
        update lead;
    }

    public static void deleteLeads(List<Lead> leads) {
        if(leads == null || leads.isEmpty()) return;
        delete leads;
    }
}