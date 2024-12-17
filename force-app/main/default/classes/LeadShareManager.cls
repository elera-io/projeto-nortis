public class LeadShareManager {

    public static void manageLeadSharing(List<Lead> updatedLeads, Map<Id, Lead> oldLeadMap) {
        List<LeadShare> sharesToInsert = new List<LeadShare>();
        List<LeadShare> sharesToDelete = new List<LeadShare>();
    
        for (Lead lead : updatedLeads) {
            Lead oldLead = oldLeadMap.get(lead.Id);
    
            if (oldLead.OwnerId != lead.OwnerId) {
                List<LeadShare> existingShares = [SELECT Id FROM LeadShare WHERE LeadId = :lead.Id AND RowCause = 'Manual'];
                for (LeadShare share : existingShares) {
                    sharesToDelete.add(share);
                }
    
                if (lead.SDRProprietario__c != null) {
                    sharesToInsert.add(createLeadShare(lead.Id, lead.SDRProprietario__c, 'Read', 'Manual'));
                    sharesToInsert.add(createLeadShare(lead.Id, lead.SDRProprietario__c, 'Edit', 'Manual'));
                }
            }
        }
    
        System.debug('Compartilhamento para ser adicionado: ' + JSON.serialize(sharesToInsert));
        System.debug('Compartilhamento para ser removido: ' + JSON.serialize(sharesToDelete));
    
        if (!sharesToDelete.isEmpty()) {
            Database.delete(sharesToDelete, false);
        }
    
        if (!sharesToInsert.isEmpty()) {
            Database.insert(sharesToInsert, false);
        }
    }

    private static LeadShare createLeadShare(Id leadId, Id userId, String accessLevel, String rowCause) {
        LeadShare leadShare = new LeadShare();
        leadShare.LeadId = leadId;
        leadShare.UserOrGroupId = userId;
        leadShare.LeadAccessLevel = accessLevel;
        leadShare.RowCause = rowCause;
        return leadShare;
    }


    public static void updateSDROwnerField(List<Lead> updatedLeads, Map<Id, Lead> oldLeadMap) {
        for (Lead lead : updatedLeads) {
            Lead oldLead = oldLeadMap.get(lead.Id);

            if (oldLead.OwnerId != lead.OwnerId) {
                if (lead.OwnerId.getSObjectType() == User.SObjectType) {
                    User newOwner = [SELECT Id, TipoUsuario__c FROM User WHERE Id = :lead.OwnerId];
                    String newOwnerType = newOwner.TipoUsuario__c;
    
                    if (newOwnerType == 'SDR') {
                        lead.SDRProprietario__c = newOwner.Id; 
                    }
                } 
            }
        }
    }
}