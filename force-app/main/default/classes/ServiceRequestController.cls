public with sharing class ServiceRequestController {

    @AuraEnabled
    public static void createServiceRequest(

        Id equipmentId,
        String description,
        String priority,
        String status

    ){

        Service_Request__c sr = new Service_Request__c();

        sr.Equipment__c = equipmentId;
        sr.Description__c = description;
        sr.Priority__c = priority;
        sr.Status__c = status;

        insert sr;

    }

}