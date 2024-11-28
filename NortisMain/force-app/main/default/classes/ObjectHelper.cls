public with sharing class ObjectHelper {
    public static Set<Id> getLookUpId(List<SObject> objects, String field){
        Set<Id> setId = new Set<Id>();

        for(SObject iObject : objects){
            if(iObject.get(field) != null){
                setId.add((Id) iObject.get(field));
            }
        }

        return setId;
    }

    public static Set<String> getFieldSet(String objectName) {
        SObjectType leadType = Schema.getGlobalDescribe().get(objectName);
        Set<String> camposLead = new Set<String>();
    
        Map<String, Schema.SObjectField> mfields = leadType.getDescribe().fields.getMap();
    
        for (String campo : mfields.keySet()) {
            if (campo != 'PrimeiroEmpreendimento__c') {
                camposLead.add(campo);
            }
        }
    
        return camposLead;
    }
    

    public static void updateFields(SObject iLead, SObject jLead, Set<String> fields){
        for(String field : fields){
            if(iLead.get(field) != null && iLead.get(field) != jLead.get(field)){
                jLead.put(field, iLead.get(field));
            }
        }
    }

    public static Boolean isEqualField(SObject iObject, SObject jObject, String field){
        return String.isNotEmpty((String) iObject.get(field)) && iObject.get(field) == jObject.get(field);
    }
    
    public static Set<Id> getIds(List<SObject> records) {
        return (new Map<Id, SObject>(records)).keySet();
    }
}