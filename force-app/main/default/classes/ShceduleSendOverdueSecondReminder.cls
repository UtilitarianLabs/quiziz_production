public class ShceduleSendOverdueSecondReminder implements Schedulable {
    public void Execute(SchedulableContext bc){
        SendOverdueSecondReminder batch = new SendOverdueSecondReminder();
        database.executeBatch(batch,20);
    }
}