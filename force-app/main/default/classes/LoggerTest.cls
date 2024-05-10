@isTest
public without sharing class LoggerTest {
	@isTest
	private static void testErrorLogCreation() {
		Exception e = new System.MathException();
		e.setMessage('Test Exception');
		Test.startTest();
		Logger.getInstance().error(e).publish();
		Test.stopTest();
		List<Log__c> logs = [
			SELECT Id, Message__c, LogLevel__c
			FROM Log__c
		];
		System.assertEquals(1, logs.size());
		System.assert(
			logs[0].Message__c.contains('Test Exception'),
			'Expected message not found in log'
		);
		System.assertEquals('ERROR', logs[0].LogLevel__c);
	}

	@isTest
	private static void testBulkErrorLogCreation() {
		Test.startTest();
		for (Integer i = 400; i > 0; i--) {
			Exception e = new System.MathException();
			e.setMessage('Test Exception' + i);
			Logger.getInstance().error(e);
		}
		System.assertEquals(
			400,
			Logger.getInstance().size(),
			'No of log events to publish'
		);
		Logger.getInstance().publish();
		Test.stopTest();
		List<Log__c> logs = [
			SELECT Id, Message__c, LogLevel__c
			FROM Log__c
		];
		System.assertEquals(400, logs.size(), 'No of log records created');
		System.assert(
			logs[0].Message__c.contains('Test Exception'),
			'Expected message not found in log'
		);
		System.assertEquals('ERROR', logs[0].LogLevel__c);
	}

	@isTest
	private static void testInfoLogCreation() {
		Exception e = new System.MathException();
		e.setMessage('Test Exception');
		Test.startTest();
		Logger.getInstance().info(e).publish();
		Test.stopTest();
		List<Log__c> logs = [
			SELECT Id, Message__c, LogLevel__c
			FROM Log__c
		];
		System.assertEquals(1, logs.size());
		System.assert(
			logs[0].Message__c.contains('Test Exception'),
			'Expected message not found in log'
		);
		System.assertEquals('INFO', logs[0].LogLevel__c);
	}

	@isTest
	private static void testBulkInfoLogCreation() {
		Test.startTest();
		for (Integer i = 400; i > 0; i--) {
			Exception e = new System.MathException();
			e.setMessage('Test Exception' + i);
			Logger.getInstance().info(e);
		}
		System.assertEquals(
			400,
			Logger.getInstance().size(),
			'No of log events to publish'
		);
		Logger.getInstance().publish();
		Test.stopTest();
		List<Log__c> logs = [
			SELECT Id, Message__c, LogLevel__c
			FROM Log__c
		];
		System.assertEquals(400, logs.size(), 'No of log records created');
		System.assert(
			logs[0].Message__c.contains('Test Exception'),
			'Expected message not found in log'
		);
		System.assertEquals('INFO', logs[0].LogLevel__c);
	}

	@isTest
	private static void testErrorDatabaseSaveresults() {
		List<Account> accounts = new List<Account>{
			new Account(Name = 'Test Account 1')
		};
		insert accounts;
		List<Contact> contacts = new List<Contact>{
			new Contact(
				FirstName = 'Test Contact 1',
				LastName = 'one',
				AccountId = accounts.get(0).Id
			)
		};
		insert contacts;

		Test.startTest();
		contacts[0].LastName = null;
		List<Database.SaveResult> saveResults = Database.update(
			contacts,
			false
		);
		Logger.getInstance().error(saveResults).publish();
		Test.stopTest();
		List<Log__c> logs = [
			SELECT Id, Message__c, LogLevel__c
			FROM Log__c
		];
		System.assertEquals(1, logs.size());
	}
}
