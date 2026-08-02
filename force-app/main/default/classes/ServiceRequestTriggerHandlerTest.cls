@isTest
public class ServiceRequestTriggerHandlerTest {

    @isTest
    static void testMaintenanceCostRollup() {

        // Create Equipment
        Equipment__c eq = new Equipment__c(
            Serial_Number__c = 'SN001',
            Category__c = 'Laptop',
            Purchase_Date__c = Date.today(),
            Warranty_Expiry__c = Date.today().addYears(1),
            Status__c = 'Active',
            Location__c = 'Office'
        );
        insert eq;

        // Create Service Request
        Service_Request__c sr = new Service_Request__c(
            Equipment__c = eq.Id,
            Description__c = 'Screen Broken',
            Priority__c = 'High',
            Status__c = 'New',
            Cost__c = 500
        );
        insert sr;

        // Close the Service Request
        sr.Status__c = 'Closed';

        Test.startTest();
        update sr;
        Test.stopTest();

        // Verify Equipment Cost Updated
        Equipment__c updatedEq = [
            SELECT Total_Maintenance_Cost__c
            FROM Equipment__c
            WHERE Id = :eq.Id
        ];

        System.assertEquals(
            500,
            updatedEq.Total_Maintenance_Cost__c
        );
    }

}