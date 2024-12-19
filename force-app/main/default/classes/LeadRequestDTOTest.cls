@isTest
private class LeadRequestDTOTest {

    @isTest
    static void testValidationSuccess() {
        LeadRequestDTO dto = new LeadRequestDTO();
        dto.nome = 'Teste Sobrenome';
        dto.telefone = '123456789';
        dto.email = 'teste@exemplo.com';
        dto.tipo = 'LeadVibra';

        String validationMessage = LeadRequestDTO.getValidationErrorMessage(dto);
        System.assertEquals(null, validationMessage, 'A validação deveria passar sem erros.');
    }

    @isTest
    static void testValidationFailure() {
        LeadRequestDTO dto = new LeadRequestDTO();
        dto.nome = ' ';
        dto.telefone = '123456789';
        dto.email = 'teste@exemplo.com';
        dto.tipo = 'LeadVibra';

        String validationMessage = LeadRequestDTO.getValidationErrorMessage(dto);
        System.assertNotEquals(null, validationMessage, 'Deveria retornar erro de validação para campos obrigatórios.');
    }

    @isTest
    static void testValidationInvalidEmpreendimento() {
        LeadRequestDTO dto = new LeadRequestDTO();
        dto.nome = 'Teste Sobrenome';
        dto.telefone = '123456789';
        dto.email = 'teste@exemplo.com';
        dto.tipo = 'LeadVibra';
        dto.empreendimento_interesse = 'INVALID_CODE';

        String validationMessage = LeadRequestDTO.getValidationErrorMessage(dto);
        System.assert(validationMessage.contains('Não foi encontrado um Empreendimento representado pelo código externo'),
            'Deveria retornar erro de validação para empreendimento inválido.');
    }

    @isTest
    static void testValidationInvalidCanal() {
        LeadRequestDTO dto = new LeadRequestDTO();
        dto.nome = 'Teste Sobrenome';
        dto.telefone = '123456789';
        dto.email = 'teste@exemplo.com';
        dto.tipo = 'LeadVibra';
        dto.canal = 'InvalidCanal';

        String validationMessage = LeadRequestDTO.getValidationErrorMessage(dto);
        System.assert(validationMessage.contains('Valor inválido para o campo canal'),
            'Deveria retornar erro de validação para canal inválido.');
    }

    @isTest
    static void testParse() {
        String json = '{"nome": "Teste Sobrenome", "telefone": "123456789", "email": "teste@exemplo.com", "tipo": "LeadVibra"}';
        LeadRequestDTO dto = LeadRequestDTO.parse(json);

        System.assertEquals('Teste Sobrenome', dto.nome, 'O campo nome deveria ser mapeado corretamente.');
        System.assertEquals('123456789', dto.telefone, 'O campo telefone deveria ser mapeado corretamente.');
        System.assertEquals('teste@exemplo.com', dto.email, 'O campo email deveria ser mapeado corretamente.');
        System.assertEquals('LeadVibra', dto.tipo, 'O campo tipo deveria ser mapeado corretamente.');
    }

    @isTest
    static void testToLead() {
        LeadRequestDTO dto = new LeadRequestDTO();
        dto.nome = 'Teste Sobrenome';
        dto.telefone = '123456789';
        dto.email = 'teste@exemplo.com';
        dto.tipo = 'LeadVibra';

        Lead lead = dto.toLead();

        System.assertEquals('Teste', lead.FirstName, 'O campo FirstName deveria ser extraído corretamente.');
        System.assertEquals('Sobrenome', lead.LastName, 'O campo LastName deveria ser extraído corretamente.');
        System.assertEquals('123456789', lead.MobilePhone, 'O campo MobilePhone deveria ser mapeado corretamente.');
        System.assertEquals('teste@exemplo.com', lead.Email, 'O campo Email deveria ser mapeado corretamente.');
    }

    @isTest
    static void testToLeadWithSingleName() {
        LeadRequestDTO dto = new LeadRequestDTO();
        dto.nome = 'Unico';
        dto.telefone = '123456789';
        dto.email = 'unico@exemplo.com';
        dto.tipo = 'LeadVibra';

        Lead lead = dto.toLead();

        System.assertEquals(null, lead.FirstName, 'O campo FirstName deveria ser nulo para nomes únicos.');
        System.assertEquals('Unico', lead.LastName, 'O campo LastName deveria conter o nome completo para nomes únicos.');
    }
}