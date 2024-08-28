public class ScheduleSendOverdueThirdReminder implements Schedulable {
    public void Execute(SchedulableContext bc){
        SendOverdueThirdReminder batch = new SendOverdueThirdReminder();
         database.executeBatch(batch,20);  
    }
}