public class SchedukeSendOverdueForthReminder implements Schedulable {
    public void Execute(SchedulableContext bc){
        SendOverdueForthReminder batch = new SendOverdueForthReminder();
        database.executeBatch(batch,20);  
    }
}