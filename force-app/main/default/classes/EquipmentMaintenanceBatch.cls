global class EquipmentMaintenanceBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            [
                SELECT Id,
                       Warranty_Expiry__c,
                       Warranty_Alert__c
                FROM Equipment__c
                WHERE Warranty_Expiry__c <= :Date.today().addDays(30)
            ]
        );
    }

    global void execute(Database.BatchableContext bc,
                        List<Equipment__c> scope) {

        Set<Id> equipmentIds = new Set<Id>();

        for(Equipment__c eq : scope){
            equipmentIds.add(eq.Id);
        }

        Set<Id> equipmentWithOpenRequests = new Set<Id>();

        for(Service_Request__c sr : [

            SELECT Equipment__c
            FROM Service_Request__c
            WHERE Equipment__c IN :equipmentIds
            AND Status__c != 'Closed'

        ]){

            equipmentWithOpenRequests.add(sr.Equipment__c);

        }

        List<Equipment__c> updateList = new List<Equipment__c>();

        for(Equipment__c eq : scope){

            if(!equipmentWithOpenRequests.contains(eq.Id)){

                eq.Warranty_Alert__c = true;
                updateList.add(eq);

            }

        }

        if(!updateList.isEmpty()){

            update updateList;

        }

    }

    global void finish(Database.BatchableContext bc){

        System.debug('Equipment Maintenance Batch Completed');

    }

}