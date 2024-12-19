@isTest
private class LeadAPIControllerTest {

    @isTest
    static void testInsertLead_Success() {
        LeadRequestDTO leadRequest = new LeadRequestDTO();
        leadRequest.nome = 'John Doe';
        leadRequest.telefone = '555-1234';
        leadRequest.email = 'johndoe@example.com';
        leadRequest.tipo = 'LeadNortis';

        String requestBody = JSON.serialize(leadRequest);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        LeadAPIController.insertLead();
        Test.stopTest();

        System.assertEquals(201, res.statusCode, 'O status code deve ser 201 para criação bem-sucedida.');
        LeadResponseDTO response = (LeadResponseDTO) JSON.deserialize(res.responseBody.toString(), LeadResponseDTO.class);
        System.assert(response.status == 'sucesso', 'A resposta deve indicar sucesso.');
    }

    @isTest
    static void testInsertLead_InvalidRequest() {
        LeadRequestDTO leadRequest = new LeadRequestDTO();
        leadRequest.nome = 'John Doe';

        String requestBody = JSON.serialize(leadRequest);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        LeadAPIController.insertLead();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'O status code deve ser 400 para requisição inválida.');
        LeadResponseDTO response = (LeadResponseDTO) JSON.deserialize(res.responseBody.toString(), LeadResponseDTO.class);
        System.assert(response.status == 'erro', 'A resposta deve indicar erro.');
        System.assert(response.message.contains('Verifique se todos os campos obrigatórios estão preenchidos'), 'A mensagem de erro deve ser clara.');
    }

    @isTest
    static void testInsertLead_ServerError() {
        
        LeadRequestDTO leadRequest = new LeadRequestDTO();
        leadRequest.nome = 'John Doe';
        leadRequest.telefone = '555-1234';
        leadRequest.email = 'johndoe@example.com';
        leadRequest.tipo = 'LeadNortis';

        String requestBody = JSON.serialize(leadRequest);

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = null;
        RestContext.response = res;

        LeadAPIController.insertLead();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'O status code deve ser 500 para erro do servidor.');
        LeadResponseDTO response = (LeadResponseDTO) JSON.deserialize(res.responseBody.toString(), LeadResponseDTO.class);
        System.assert(response.status == 'erro', 'A resposta deve indicar erro.');
        System.assert(response.message.contains('Ocorreu um erro no servidor'), 'A mensagem deve indicar um erro no servidor.');
    }
}