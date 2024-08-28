public class ScheduleSendOverdueFirstReminder implements Schedulable {

    public void Execute(SchedulableContext bc){
         SendOverdueFirstReminderBatch batch = new SendOverdueFirstReminderBatch();
        database.executeBatch(batch,20);
    }
}