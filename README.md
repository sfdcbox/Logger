# Logger

This SFDX project is designed to capture information and errors into a Log object. This framework systematically records essential details such as Class Name, Method Name, Line Number, Messages, Context, Stack Trace, and additional pertinent information. Its purpose is to provide comprehensive logging capabilities for efficient monitoring and debugging within the Salesforce environment.

## Usage

To log a simple text

```bash
Logger.getInstance().info('Simple info text').publish();
Logger.getInstance().addError('Simple error text').publish();
```

![image](https://github.com/gskumar1609/Logger/assets/55816916/f27dfe6e-4734-469c-9ecb-75e4312cd80a)

To capture exception information

```bash
try{

}catch(Exception e){
    Logger.getInstance().addError(e).publish();
}
```

![image](https://github.com/gskumar1609/Logger/assets/55816916/80a378ae-666c-4c19-99e8-95435b5b0119)

To capture errors in List<Database.SaveResult>

```bash
Database.SaveResult[] result = Database.update(records, false);
Logger.getInstance().addError(result).publish();
```

To log SOQL queries consumed, rows retrieved, CPU time consumed and Heap size use below statement

```bash
Logger.logLimits();
```

![image](https://github.com/gskumar1609/Logger/assets/55816916/78d2f630-ff23-4283-97d2-f228f1edf605)

Additionally, this framework logs BatchApexErrorEvent platform events, which capture information from all batches raising BatchApexErrorEvent platform events. To utilize this feature, the only requirement is to implement Database.RaisesPlatformEvents on the batch class.

```bash
public class <BatchClassName> implements Database.Batchable<sObject>, Database.RaisesPlatformEvents{

}
```

![image](https://github.com/gskumar1609/Logger/assets/55816916/3bb224ae-a187-4fcd-9c89-7f419e4d5085)
