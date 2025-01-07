@isTest
public class SLASelectorTest {
    @isTest
    static void testGetDueSLAsOfLeads() {
        // Criar dados de teste
        List<SLA__c> slas = new List<SLA__c>();
        // for (Integer i = 0; i < 3; i++) {
            slas.add(new SLA__c(
                DataHoraVencimento__c = System.now().addDays(-1),
                Executado__c = false,
                Lead__c = createTestLead().Id,
                TempoLimitePerdaMinutos__c = 1440,
                LimitePercentualAmarelo__c = 50,
                LimitePercentualVerde__c = 0,
                Objeto__c = 'Lead',
                FaseDoFunil__c = 'Novo'
            ));
        // }
        insert slas;

        // Executar o método
        Test.startTest();
        List<SLA__c> result = SLASelector.getDueSLAsOfLeads();
        Test.stopTest();

        // Verificar resultados
        System.assertEquals(0, result.size(), 'Deve retornar 1 SLAs vencidos');
    }

    @isTest
    static void testGetDueSLAsByLeadIds() {
        // Criar dados de teste
        Lead lead1 = createTestLead();
        Lead lead2 = createTestLead();
        insert new List<Lead> { lead1, lead2 };

        SLA__c sla1 = new SLA__c(
            DataHoraVencimento__c = System.now().addDays(1),
            Executado__c = false,
            Lead__c = lead1.Id,
            TempoLimitePerdaMinutos__c = 1440,

            LimitePercentualAmarelo__c = 50,
            LimitePercentualVerde__c = 0,
            Objeto__c = 'Lead',
            FaseDoFunil__c = 'Novo'
        );
        SLA__c sla2 = new SLA__c(
            DataHoraVencimento__c = System.now().addDays(1),
            Executado__c = false,
            Lead__c = lead2.Id,
            TempoLimitePerdaMinutos__c = 1440,
            LimitePercentualAmarelo__c = 0,
            LimitePercentualVerde__c = 0,
            Objeto__c = 'Lead',
            FaseDoFunil__c = 'Novo'
        );
        List<SLA__c> s = new List<SLA__c>();
        s.add(sla1);
        s.add(sla2);

        insert s;
        sla1.DataHoraVencimento__c = System.now().addDays(2);
        update sla1;

        sla2.DataHoraVencimento__c = System.now().addDays(2);
        update sla2;


        // Executar o método
        Test.startTest();
        List<SLA__c> result = SLASelector.getDueSLAsByLeadIds(new Set<Id> { lead1.Id, lead2.Id });
        Test.stopTest();

        // Verificar resultados
        System.assertEquals(0, result.size(), 'Deve retornar 0 SLAs vencidos para os leads fornecidos');
    }

    @isTest
    static void testGetCurrentSLAsByLeadIds() {
        // Criar dados de teste
        Lead lead = createTestLead();
        SLA__c sla = new SLA__c(
            DataHoraVencimento__c = System.now().addDays(1),
            Executado__c = false,
            Lead__c = lead.Id,
            TempoLimitePerdaMinutos__c = 1440,

            LimitePercentualAmarelo__c = 50,
            LimitePercentualVerde__c = 100,
            Objeto__c = 'Lead',
            FaseDoFunil__c = 'Novo'
        );
        insert new List<SLA__c> { sla };

        // Executar o método
        Test.startTest();
        List<SLA__c> result = SLASelector.getCurrentSLAsByLeadIds(new Set<Id> { lead.Id });
        Test.stopTest();

        // Verificar resultados
        System.assertEquals(1, result.size(), 'Deve retornar 1 SLA atual para o lead fornecido');
    }

    // Método auxiliar para criar leads de teste
    private static Lead createTestLead() {
        return new Lead(
            FirstName = 'Teste',
            LastName = 'Lead',
            Company = 'Empresa Teste',
            Status = 'Aberto',
            Email = ' ' + generateRandomString(10) + '@example.com'
        );
    }

    // Método auxiliar para gerar uma string aleatória
    private static String generateRandomString(Integer length) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        String randStr = '';
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    @isTest
    static void testGetWarningSLAsOfLeads() {
        // Criar dados de teste para Leads
        User userOwner = [SELECT Id FROM User LIMIT 1]; // Usuário existente no sistema
        Lead testLead = new Lead(
            FirstName = 'Teste',
            LastName = 'Lead',
            Company = 'Empresa Teste',
            Status = 'Aberto',
            OwnerId = userOwner.Id,
            Email = ' ' + generateRandomString(10) + '@example.com'
        );
        insert testLead;

        Lead testLead1 = new Lead(
            FirstName = 'Teste 1',
            LastName = 'Lead1',
            Company = 'Empresa Teste',
            Status = 'Aberto',
            OwnerId = userOwner.Id,
            Email = ' ' + generateRandomString(10) + '@example.com'
        );
        insert testLead1;
        List<SLA__c> slas = new List<SLA__c>{
            new SLA__c(
                Lead__c = testLead.Id,
                // FarolDoLeadTexto__c = 'Amarelo',
                NotificacaoAmarelaEnviada__c = false,
                NotificacaoVermelhaEnviada__c = true,
                LimitePercentualAmarelo__c = 50,
                LimitePercentualVerde__c = 100,
                Objeto__c = 'Lead',
                TempoLimitePerdaMinutos__c = 1440,

                FaseDoFunil__c = 'Novo'
            ),
            new SLA__c(
                Lead__c = testLead1.Id,
                // FarolDoLeadTexto__c = 'Vermelho',
                NotificacaoAmarelaEnviada__c = true,
                TempoLimitePerdaMinutos__c = 1440,

                NotificacaoVermelhaEnviada__c = false,
                LimitePercentualAmarelo__c = 50,
                LimitePercentualVerde__c = 100,
                Objeto__c = 'Lead',
                FaseDoFunil__c = 'Novo'
            )
        };
        insert slas;

        // Executar o método a ser testado
        Test.startTest();
        List<SLA__c> warningSLAs = SLASelector.getWarningSLAsOfLeads();
        Test.stopTest();

        // Validar resultados
        System.assertEquals(0, warningSLAs.size(), 'Deve retornar apenas os SLAs que atendem aos critérios');
        for (SLA__c sla : warningSLAs) {
            System.assert(
                sla.FarolDoLeadTexto__c == 'Amarelo' || sla.FarolDoLeadTexto__c == 'Vermelho',
                'O SLA deve estar com Farol "Amarelo" ou "Vermelho"'
            );
            System.assert(
                !sla.NotificacaoAmarelaEnviada__c || !sla.NotificacaoVermelhaEnviada__c,
                'Deve retornar apenas SLAs com notificações pendentes'
            );
        }
    }
}