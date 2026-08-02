global class EquipmentMaintenanceScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Database.executeBatch(
            new EquipmentMaintenanceBatch(),
            200
        );

    }

}