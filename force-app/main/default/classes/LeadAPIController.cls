@RestResource(urlMapping = '/leads')
global with sharing class LeadAPIController {
    
    private static final Id LEAD_VIBRA_RECORD_TYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('LeadVibra').getRecordTypeId();
    private static final Id LEAD_NORTIS_RECORD_TYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('LeadNortis').getRecordTypeId();

    public class LeadAPIException extends Exception {}

    @HttpPost
    global static void insertLead() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        response.addHeader('Content-Type', 'application/json');
        
        try {
            LeadRequestDTO leadRequest = LeadRequestDTO.parse(RestContext.request.requestBody.toString());
            
            String validationErrorMessage = LeadRequestDTO.getValidationErrorMessage(leadRequest);

            if (validationErrorMessage != null) {
                response.statusCode = 400;
    
                response.responseBody = Blob.valueOf(JSON.serialize(new LeadResponseDTO(
                    'Requisição inválida: ' + validationErrorMessage,
                    false
                ), true));
    
                return;
            }
            
            Lead leadData = leadRequest.toLead();
            leadData.RecordTypeId = LEAD_VIBRA_RECORD_TYPE_ID;

            insert leadData;

            response.statusCode = 201;

            response.responseBody = Blob.valueOf(JSON.serialize(new LeadResponseDTO(
                'Lead criado com sucesso.',
                true,
                leadData.Id
            ), true));

        } catch (Exception e) {
            response.statusCode = 500;

            response.responseBody = Blob.valueOf(JSON.serialize(new LeadResponseDTO(
                'Ocorreu um erro no servidor: ' + e.getTypeName() + ': ' + e.getMessage() + ' - ' + e.getStackTraceString(),
                false
            ), true));
        }
    }
}