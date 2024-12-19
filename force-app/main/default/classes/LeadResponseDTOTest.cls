@isTest
private class LeadResponseDTOTest {

    @isTest
    static void testConstructorWithLeadId_Success() {
        LeadResponseDTO response = new LeadResponseDTO('Lead criado com sucesso.', true, '12345');

        System.assertEquals('Lead criado com sucesso.', response.message, 'A mensagem deve ser configurada corretamente.');
        System.assertEquals('sucesso', response.status, 'O status deve ser configurado como "sucesso" para sucesso.');
    }

    @isTest
    static void testConstructorWithLeadId_Error() {
        LeadResponseDTO response = new LeadResponseDTO('Erro ao criar lead.', false, '12345');

        System.assertEquals('Erro ao criar lead.', response.message, 'A mensagem deve ser configurada corretamente.');
        System.assertEquals('erro', response.status, 'O status deve ser configurado como "erro" para erro.');
    }

    @isTest
    static void testConstructorWithoutLeadId_Success() {
        LeadResponseDTO response = new LeadResponseDTO('Lead criado com sucesso.', true);

        System.assertEquals('Lead criado com sucesso.', response.message, 'A mensagem deve ser configurada corretamente.');
        System.assertEquals('sucesso', response.status, 'O status deve ser configurado como "sucesso" para sucesso.');
    }

    @isTest
    static void testConstructorWithoutLeadId_Error() {
        LeadResponseDTO response = new LeadResponseDTO('Erro ao criar lead.', false);

        System.assertEquals('Erro ao criar lead.', response.message, 'A mensagem deve ser configurada corretamente.');
        System.assertEquals('erro', response.status, 'O status deve ser configurado como "erro" para erro.');
    }

    @isTest
    static void testDefaultConstructor() {
        LeadResponseDTO response = new LeadResponseDTO();

        System.assertEquals(null, response.message, 'A mensagem deve ser nula no construtor padrão.');
        System.assertEquals(null, response.status, 'O status deve ser nulo no construtor padrão.');
    }
}