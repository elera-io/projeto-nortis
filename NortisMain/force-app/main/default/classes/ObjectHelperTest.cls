@isTest
private class ObjectHelperTest {

    @isTest
    static void testGetLookUpId() {
        // Criando registros de exemplo
        Account acc1 = new Account(Name = 'Account 1');
        insert acc1;
        Account acc2 = new Account(Name = 'Account 2');
        insert acc2;
        
        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc1.Id);
        Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = acc2.Id);
        insert new List<Contact>{ contact1, contact2 };

        // Testando o método getLookUpId
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id IN :new Set<Id>{contact1.Id, contact2.Id}];
        Set<Id> lookupIds = ObjectHelper.getLookUpId(contacts, 'AccountId');

        // Validando os resultados
        System.assertEquals(2, lookupIds.size(), 'Deve retornar dois IDs de Account');
        System.assert(lookupIds.contains(acc1.Id), 'Deve conter o ID de Account1');
        System.assert(lookupIds.contains(acc2.Id), 'Deve conter o ID de Account2');
    }

    @isTest
    static void testGetFieldSet() {
        // Testando o método getFieldSet para o objeto Account
        Set<String> fields = ObjectHelper.getFieldSet('Account');
        
        // Validando se o campo "PrimeiroEmpreendimento__c" foi excluído
        System.assert(!fields.contains('PrimeiroEmpreendimento__c'), 'O campo PrimeiroEmpreendimento__c não deve estar no conjunto');
        
    }

    @isTest
    static void testUpdateFields() {
        // Criando e inserindo registros
        Account acc1 = new Account(Name = 'Account 1', Phone = '12345');
        Account acc2 = new Account(Name = 'Account 2', Phone = '67890');
        insert new List<Account>{ acc1, acc2 };

        // Modificando os campos
        acc1.Phone = '54321';
        acc2.Phone = '67890';

        Set<String> fields = new Set<String>{ 'Phone' };

        // Testando o método updateFields
        ObjectHelper.updateFields(acc1, acc2, fields);

        // Atualizando explicitamente o registro acc2
        update acc2;

        // Consultando novamente para validar a atualização
        Account updatedAcc2 = [SELECT Phone FROM Account WHERE Id = :acc2.Id];

        // Validando que o campo Phone foi atualizado
        System.assertEquals('54321', updatedAcc2.Phone, 'O campo Phone de acc2 deve ser atualizado');
    }

    @isTest
    static void testIsEqualField() {
        // Criando registros de exemplo
        Account acc1 = new Account(Name = 'Account 1', Phone = '12345');
        Account acc2 = new Account(Name = 'Account 2', Phone = '12345');
        Account acc3 = new Account(Name = 'Account 3', Phone = '67890');
        insert new List<Account>{ acc1, acc2, acc3 };

        // Testando o método isEqualField
        Boolean isEqual = ObjectHelper.isEqualField(acc1, acc2, 'Phone');
        System.assert(isEqual, 'O campo Phone deve ser igual para acc1 e acc2');

        isEqual = ObjectHelper.isEqualField(acc1, acc3, 'Phone');
        System.assert(!isEqual, 'O campo Phone não deve ser igual para acc1 e acc3');
    }

    @isTest
    static void testGetIds() {
        // Criando registros de exemplo
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');
        insert new List<Account>{ acc1, acc2 };

        // Testando o método getIds
        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :new Set<Id>{acc1.Id, acc2.Id}];
        Set<Id> ids = ObjectHelper.getIds(accounts);

        // Validando os resultados
        System.assertEquals(2, ids.size(), 'Deve retornar dois IDs');
        System.assert(ids.contains(acc1.Id), 'Deve conter o ID de acc1');
        System.assert(ids.contains(acc2.Id), 'Deve conter o ID de acc2');
    }
}
