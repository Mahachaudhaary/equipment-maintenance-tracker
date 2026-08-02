trigger ServiceRequestTrigger on Service_Request__c (after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        ServiceRequestTriggerHandler.updateMaintenanceCost(
            Trigger.new,
            Trigger.oldMap
        );
    }

}