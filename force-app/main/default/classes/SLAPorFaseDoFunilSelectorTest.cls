@isTest
public class SLAPorFaseDoFunilSelectorTest {
    @isTest
    static void testGetLeadSLAPerFunnelPhase() {
        List<RecordType> recordTypes = new List<RecordType>{
            new RecordType(SObjectType = 'SLAPorFaseDoFunil__c', DeveloperName = 'RegraSLANortis', Name = 'Regra de SLA Nortis'),
            new RecordType(SObjectType = 'SLAPorFaseDoFunil__c', DeveloperName = 'RegraSLAVibra', Name = 'Regra de SLA Vibra')
        };

        Map<String, Schema.RecordTypeInfo> slaRecordTypes = Schema.SObjectType.SLAPorFaseDoFunil__c.getRecordTypeInfosByDeveloperName();

        Map<String, Id> recordTypeMap = new Map<String, Id>();
        recordTypeMap.put('RegraSLANortis', slaRecordTypes.get('RegraSLANortis').getRecordTypeId());
        recordTypeMap.put('RegraSLAVibra', slaRecordTypes.get('RegraSLAVibra').getRecordTypeId());

        List<SLAPorFaseDoFunil__c> slaRecords = new List<SLAPorFaseDoFunil__c>{
            new SLAPorFaseDoFunil__c(
                Name = 'Teste 1',
                FaseRedirecionamento__c = 'Pesquisa',
                FilaRedirecionamento__c = 'SDRNortis',
                FaseDoFunil__c = 'Novo',
                LimitePercentualAmarelo__c = 50,
                LimitePercentualVerde__c = 100,
                Objeto__c = 'Lead',
                TempoLimitePerdaMinutos__c = 60,
                RecordTypeId = recordTypeMap.get('RegraSLANortis')
            ),
            new SLAPorFaseDoFunil__c(
                Name = 'Teste 2',
                FaseRedirecionamento__c = 'Pesquisa',
                FilaRedirecionamento__c = 'SDRNortis',
                FaseDoFunil__c = 'Novo',
                LimitePercentualAmarelo__c = 30,
                LimitePercentualVerde__c = 70,
                Objeto__c = 'Lead',
                TempoLimitePerdaMinutos__c = 120,
                RecordTypeId = recordTypeMap.get('RegraSLANortis')
            )
        };
       

        insert slaRecords;

        Test.startTest();
        List<SLAPorFaseDoFunil__c> results = SLAPorFaseDoFunilSelector.getLeadSLAPerFunnelPhase();
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Deve retornar apenas registros com Objeto__c = "Lead"');
        System.assertEquals('Lead', results[0].Objeto__c, 'O Objeto__c do registro retornado deve ser "Lead"');
    }

    private static Id getTestRecordTypeId(String sObjectName, String developerName) {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = :sObjectName AND DeveloperName = :developerName LIMIT 1];
        if (recordTypes.isEmpty()) {
            return null; 
        }
        return recordTypes[0].Id;
    }
}
