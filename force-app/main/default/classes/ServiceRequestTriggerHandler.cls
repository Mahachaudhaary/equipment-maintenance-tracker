public with sharing class ServiceRequestTriggerHandler {

    public static void updateMaintenanceCost(
        List<Service_Request__c> newList,
        Map<Id, Service_Request__c> oldMap
    ) {

        // Store Equipment IDs whose requests were just closed
        Set<Id> equipmentIds = new Set<Id>();

        // Check which Service Requests changed to Closed
        for(Service_Request__c sr : newList){

            Service_Request__c oldSr = oldMap.get(sr.Id);

            if(sr.Status__c == 'Closed'
               && oldSr.Status__c != 'Closed'
               && sr.Equipment__c != null){

                equipmentIds.add(sr.Equipment__c);

            }
        }

        // Nothing to update
        if(equipmentIds.isEmpty()){
            return;
        }

        // Calculate total maintenance cost
        Map<Id, Decimal> equipmentCostMap = new Map<Id, Decimal>();

        for(AggregateResult ar : [

            SELECT Equipment__c equipmentId,
                   SUM(Cost__c) totalCost
            FROM Service_Request__c
            WHERE Equipment__c IN :equipmentIds
            AND Status__c = 'Closed'
            GROUP BY Equipment__c

        ]){

            equipmentCostMap.put(

                (Id)ar.get('equipmentId'),
                (Decimal)ar.get('totalCost')

            );
        }

        // Update Equipment
        List<Equipment__c> equipmentToUpdate = new List<Equipment__c>();

        for(Id eqId : equipmentIds){

            Equipment__c eq = new Equipment__c();

            eq.Id = eqId;

            if(equipmentCostMap.containsKey(eqId)){
                eq.Total_Maintenance_Cost__c =
                    equipmentCostMap.get(eqId);
            }
            else{
                eq.Total_Maintenance_Cost__c = 0;
            }

            equipmentToUpdate.add(eq);

        }

        if(!equipmentToUpdate.isEmpty()){
            update equipmentToUpdate;
        }

    }

}