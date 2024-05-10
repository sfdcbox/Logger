public without sharing class LogEntry {
  public String className { get; set; }
  public String executionContext { get; set; }
  public Decimal lineNumber { get; set; }
  public System.LoggingLevel logLevel { get; set; }
  public String message { get; set; }
  public String stackTrace { get; set; }
  public String methodName { get; set; }
  public Id userId { get; set; }
  //public Datetime createdDatetime { get; set; }

  /*public LogEntry() {
		this(System.LoggingLevel.INFO, null);
	}*/

  public LogEntry(System.LoggingLevel loggingLevel, String message) {
    this.executionContext =
      Request.getCurrent().getRequestId() +
      '/' +
      Request.getCurrent().getQuiddity();
    this.logLevel = loggingLevel;
    if(message.contains('Stack trace:')){
      this.stackTrace = message.substringAfter('Stack trace:');
      this.message = message.substringBefore('Stack trace:');
    }else{
      this.message = message;
    }
    this.userId = System.UserInfo.getUserId();
  }

  /*public LogEntry(LogEvent__e logEvent) {
		this.className = logEvent.ClassName__c;
		this.executionContext = logEvent.ExecutionContext__c;
		this.lineNumber = logEvent.LineNumber__c;
		this.logLevel = System.LoggingLevel.valueOf(logEvent.LogLevel__c);
		this.message = logEvent.Message__c;
		this.methodName = logEvent.MethodName__c;
		this.userId = logEvent.CreatedById;
		this.createdDatetime = logEvent.CreatedDate;
	}*/

  public LogEvent__e toPlatformEvent() {
    Integer maxSize = 131072;
    if (this.message.length() > maxSize) {
      this.message = this.message.substring(0, maxSize);
    }
    return new LogEvent__e(
      ClassName__c = this.className,
      ExecutionContext__c = this.executionContext,
      LineNumber__c = this.lineNumber,
      LogLevel__c = this.logLevel.name(),
      Message__c = this.message,
      MethodName__c = this.methodName,
      StackTrace__c = this.stackTrace
    );
  }
}
