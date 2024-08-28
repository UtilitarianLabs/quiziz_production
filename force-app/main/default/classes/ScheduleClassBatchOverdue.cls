public class ScheduleClassBatchOverdue implements  Schedulable {
    
    public void execute(SchedulableContext SC) {
        SendOverdueFirstReminderBatch batchable = new SendOverdueFirstReminderBatch();
        database.executeBatch(batchable);
        
        SendOverdueSecondReminder secondBatch = new SendOverdueSecondReminder();
        database.executeBatch(secondBatch);
        
        SendOverdueThirdReminder thirdBatch = new SendOverdueThirdReminder();
        database.executeBatch(thirdBatch);
        
        SendOverdueForthReminder fourthBatch = new SendOverdueForthReminder();
        database.executeBatch(fourthBatch);
        
        SendOverdueFifthReminder fifthBatch = new SendOverdueFifthReminder();
        database.executeBatch(fifthBatch);
    }
}