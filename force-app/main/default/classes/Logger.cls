public without sharing class Logger {
  public static final String LF = '\n';
  public static final String CR = '\r';

  private static final String ORG_NAMESPACE = [
    SELECT NamespacePrefix
    FROM Organization
  ]
  .NamespacePrefix;
  private static final String CLASSNAME = Logger.class.getName();
  private static final Pattern STACK_LINE = Pattern.compile(
    '^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$'
  );

  private LogMessageFormatter messageFormatter = new LogMessageFormatter();

  private static Logger instance;

  private List<LogEvent__e> logEvents = new List<LogEvent__e>();

  public static Logger getInstance() {
    if (instance == null) {
      instance = newInstance();
    }

    return instance;
  }

  public Integer size() {
    return logEvents.size();
  }

  public static Logger newInstance() {
    return new Logger();
  }

  /*
		WILL USE IN FUTURE
	public void debug(Exception e) {
		add(System.LoggingLevel.DEBUG, e);
	}

	public void debug(String message) {
		add(System.LoggingLevel.DEBUG, message);
	}

	public void debug(String message, List<String> args) {
		add(System.LoggingLevel.DEBUG, message, args);
	}*/

  public Logger error(Exception e) {
    add(System.LoggingLevel.ERROR, e);
    return this;
  }

  public static void logError(Exception e) {
    Logger.getInstance().error(e).publish();
  }

  public Logger error(List<Database.SaveResult> saveResults) {
    add(System.LoggingLevel.ERROR, saveResults);
    return this;
  }

  public static void logError(List<Database.SaveResult> saveResults) {
    Logger.getInstance().error(saveResults).publish();
  }

  public Logger error(String message) {
    add(System.LoggingLevel.ERROR, message);
    return this;
  }

  public static void logError(String message) {
    Logger.getInstance().error(message).publish();
  }

  /*	WILL USE IN FUTURE
	public Logger error(String message, List<String> args) {
		add(System.LoggingLevel.ERROR, message, args);
		return this;
	}
	*/

  public Logger info(Exception e) {
    add(System.LoggingLevel.INFO, e);
    return this;
  }
  /*	WILL USE IN FUTURE
	public Logger info(APIException e) {
		add(System.LoggingLevel.INFO, e);
		return this;
	}*/

  public Logger info(String message) {
    add(System.LoggingLevel.INFO, message);
    return this;
  }

  public static void logInfo(String message) {
    Logger.getInstance().info(message).publish();
  }

  /*
	public Logger info(String message, List<String> args) {
		add(System.LoggingLevel.INFO, message, args);
		return this;
	}
*/
  public void add(LoggingLevel loggingLevel, Exception e) {
    add(new LogEntry(loggingLevel, messageFormatter.format(e)));
  }

  /*	public void add(LoggingLevel loggingLevel, APIException e) {
		add(new LogEntry(loggingLevel, messageFormatter.format(e)));
	}*/

  public void add(
    LoggingLevel loggingLevel,
    List<Database.SaveResult> saveResults
  ) {
    String fomattedSaveResults = messageFormatter.format(saveResults);
    if (String.isNotBlank(fomattedSaveResults)) {
      add(new LogEntry(loggingLevel, fomattedSaveResults));
    }
  }

  public void add(String message) {
    add(System.LoggingLevel.INFO, message);
  }

  public void add(LoggingLevel loggingLevel, String message) {
    add(new LogEntry(loggingLevel, messageFormatter.format(message)));
  }

  public void add(
    LoggingLevel loggingLevel,
    String message,
    List<String> args
  ) {
    add(new LogEntry(loggingLevel, messageFormatter.format(message, args)));
  }

  private void add(LogEntry logEntry) {
    populateStackTrace(logEntry);
    logEvents.add(logEntry.toPlatformEvent());
    //publishEvent(logEntry);
  }

  private void populateStackTrace(LogEntry logEntry) {
    List<String> stacktrace = new DmlException()
      .getStackTraceString()
      .split('\n');

    for (String line : stacktrace) {
      Matcher matcher = STACK_LINE.matcher(line);

      if (matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
        Boolean hasNamespace = String.isNotBlank(matcher.group(3));

        if (hasNamespace) {
          logEntry.className = (matcher.group(1).equals(ORG_NAMESPACE))
            ? matcher.group(2)
            : matcher.group(1) + '.' + matcher.group(2);

          logEntry.methodName = formatMethodName(matcher.group(3));
        } else {
          logEntry.className = matcher.group(1);
          logEntry.methodName = formatMethodName(matcher.group(2));
        }

        logEntry.lineNumber = Integer.valueOf(matcher.group(4));
        return;
      }
    }
  }

  private String formatMethodName(String method) {
    String result = (method == null) ? 'anonymous' : method;
    return (result.contains('init')) ? 'ctor' : result;
  }

  public static void logLimits() {
    String limitsConsumed =
      'CPU TIME : ' +
      Limits.getCpuTime() +
      '\n' +
      'HEAP SIZE : ' +
      String.valueOf(Limits.getHeapSize()) +
      '\n' +
      'QUERY ROWS : ' +
      String.valueOf(Limits.getQueryRows()) +
      '\n' +
      'QUERIES PERFORMED : ' +
      String.valueOf(Limits.getQueries()) +
      '\n' +
      'QUERIES REMAINING : ' +
      String.valueOf(Limits.getLimitQueries() - Limits.getQueries());
    Logger.getInstance().info(limitsConsumed).publish();
  }

  public void publish() {
    publishEvents(logEvents);
    logEvents = new List<LogEvent__e>();
  }

  private void publishEvent(LogEntry entry) {
    publishEvents(new List<LogEvent__e>{ entry.toPlatformEvent() });
  }

  private void publishEvents(List<LogEvent__e> events) {
    if (events.isEmpty())
      return;

    List<Database.SaveResult> results = EventBus.publish(events);
    //checkAndReportErrors(results);  TODO: check and report event creation errors
  }

  public virtual class LogMessageFormatter {
    public String format(String message) {
      return message;
    }

    public String format(String message, List<String> args) {
      return String.format(message, args);
    }

    public String format(Exception e) {
      String result = 'Exception: ' + e;
      if (String.isNotBlank(e.getMessage())) {
        result = result.remove(e.getMessage());
        result += LF + ' Message: ' + e.getMessage();
      }
      if (null != e.getCause()) {
        result += LF + ' Cause: ' + e.getCause();
      }
      result += LF + ' Stack trace: ' + e.getStackTraceString();

      return result;
    }

    public String format(List<Database.SaveResult> saveResults) {
      String errorMessage = '';
      for (Database.SaveResult saveResult : saveResults) {
        if (!saveResult.isSuccess()) {
          errorMessage += format(saveResult);
        }
      }
      return errorMessage;
    }

    public String format(Database.SaveResult saveResult) {
      String errorMessage = 'SaveResult Errors : ';
      for (Database.Error databaseError : saveResult.getErrors()) {
        errorMessage +=
          'Id : ' +
          saveResult.getId() +
          ', Errors : ' +
          String.format(
            ' {0} - {1}, ',
            new List<String>{
              String.valueOf(databaseError.getStatusCode()),
              databaseError.getMessage()
            }
          );
      }
      return errorMessage;
    }
  }
}
