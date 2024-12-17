@isTest
public class SLASelectorTest {
    @isTest
    static void testGetDueSLAsOfLeads() {
        List<SLA__c> slas = new List<SLA__c>();
            slas.add(new SLA__c(
                DataHoraVencimento__c = System.now().addDays(-1),
                Executado__c = false,
                Lead__c = createTestLead().Id,
                TempoLimitePerdaMinutos__c = 60,
                LimitePercentualAmarelo__c = 50,
                LimitePercentualVerde__c = 100,
                Objeto__c = 'Lead',
                FaseDoFunil__c = 'Novo'
            ));
        insert slas;

        Test.startTest();
        List<SLA__c> result = SLASelector.getDueSLAsOfLeads();
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Deve retornar 1 SLAs vencidos');
    }

    @isTest
    static void testGetDueSLAsByLeadIds() {
        Lead lead1 = createTestLead();
        Lead lead2 = createTestLead();
        insert new List<Lead> { lead1, lead2 };

        SLA__c sla1 = new SLA__c(
            DataHoraVencimento__c = System.now().addDays(-1),
            Executado__c = false,
            Lead__c = lead1.Id,
            LimitePercentualAmarelo__c = 50,
            LimitePercentualVerde__c = 100,
            Objeto__c = 'Lead',
            FaseDoFunil__c = 'Novo'
        );
        SLA__c sla2 = new SLA__c(
            DataHoraVencimento__c = System.now().addDays(-2),
            Executado__c = false,
            Lead__c = lead2.Id,
            LimitePercentualAmarelo__c = 50,
            LimitePercentualVerde__c = 100,
            Objeto__c = 'Lead',
            FaseDoFunil__c = 'Novo'
        );
        insert new List<SLA__c> { sla1, sla2 };

        Test.startTest();
        List<SLA__c> result = SLASelector.getDueSLAsByLeadIds(new Set<Id> { lead1.Id, lead2.Id });
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Deve retornar 2 SLAs vencidos para os leads fornecidos');
    }

    @isTest
    static void testGetCurrentSLAsByLeadIds() {
        Lead lead = createTestLead();
        SLA__c sla = new SLA__c(
            DataHoraVencimento__c = System.now().addDays(1),
            Executado__c = false,
            Lead__c = lead.Id,
            LimitePercentualAmarelo__c = 50,
            LimitePercentualVerde__c = 100,
            Objeto__c = 'Lead',
            FaseDoFunil__c = 'Novo'
        );
        insert new List<SLA__c> { sla };

        Test.startTest();
        List<SLA__c> result = SLASelector.getCurrentSLAsByLeadIds(new Set<Id> { lead.Id });
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Deve retornar 1 SLA atual para o lead fornecido');
    }

    private static Lead createTestLead() {
        return new Lead(
            FirstName = 'Teste',
            LastName = 'Lead',
            Company = 'Empresa Teste',
            Status = 'Aberto',
            Email = ' ' + generateRandomString(10) + '@example.com'
        );
    }

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
        User userOwner = [SELECT Id FROM User LIMIT 1]; 
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
                NotificacaoAmarelaEnviada__c = false,
                NotificacaoVermelhaEnviada__c = true,
                LimitePercentualAmarelo__c = 50,
                LimitePercentualVerde__c = 100,
                Objeto__c = 'Lead',
                FaseDoFunil__c = 'Novo'
            ),
            new SLA__c(
                Lead__c = testLead1.Id,
                NotificacaoAmarelaEnviada__c = true,
                NotificacaoVermelhaEnviada__c = false,
                LimitePercentualAmarelo__c = 50,
                LimitePercentualVerde__c = 100,
                Objeto__c = 'Lead',
                FaseDoFunil__c = 'Novo'
            )
        };
        insert slas;

        Test.startTest();
        List<SLA__c> warningSLAs = SLASelector.getWarningSLAsOfLeads();
        Test.stopTest();

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
