public with sharing class HttpRequestService {

	static final String NEWLINERETURN = '\n\r';

	HttpRequest request;
	HttpResponse response;

	private HttpRequestService() {
		request = new HttpRequest();
	}

	public static HttpRequestService newInstance() {
		return new HttpRequestService();
	}

	public HttpRequestService setEndPoint(String endPoint) {
		request.setEndpoint(endpoint);
		return this;
	}

	public HttpRequestService setHeader(String attribute, String value) {
		request.setHeader(attribute, value);
		return this;
	}

	public HttpRequestService setContentType(String value) {
		request.setHeader('Content-Type', value);
		return this;
	}

	public HttpRequestService setAuthorization(String value) {
		request.setHeader('Authorization', value);
		return this;
	}

	public HttpRequestService setBody(String body) {
		request.setBody(body);
		return this;
	}

	public HttpRequestService doPost() {
		request.setMethod('POST');
		response = new Http().send(request);
		return this;
	}

	public HttpRequestService doGet() {
		request.setMethod('GET');
		response = new Http().send(request);
		return this;
	}

	public HttpRequestService log() {
		try {
			Log__c log = new Log__c();
			log.Generated_Date_Time__c = System.now();
			log.Response_StatusCode__c = response.getStatusCode();
			log.Response_Status__c = response.getStatus();
			Database.insert(log, true);

			Attachment attachment = new Attachment();
			attachment.Body = Blob.valueOf(
				request.toString() +
					NEWLINERETURN +
					'BODY : ' +
					NEWLINERETURN +
					request.getBody() +
					NEWLINERETURN +
					response.toString() +
					NEWLINERETURN +
					'BODY : ' +
					NEWLINERETURN +
					response.getBody()
			);
			attachment.Name =
				'API_Call_' +
				System.now().format('yyyy_MM_dd_hh_mm_ss') +
				'.txt';
			attachment.ParentId = log.Id;
			Database.insert(attachment, true);
		} catch (Exception e) {
		}
		return this;
	}

	public HttpResponse getResponse() {
		return response;
	}

	public String getStringBodyToken(String token) {
		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
			response.getBody()
		);
		return responseMap.containsKey(token)
			? (String) responseMap.get(token)
			: null;
	}
}


/**
 * 
		HttpRequestService service = HttpRequestService.newInstance()
			.setEndPoint('callout:AcqueonAPI/LCM/UploadContacts')
			.setContentType('application/json')
			.setBody(JSON.serialize(body))
			.doPost();

	 	HttpResponse uploadContactsHttpResponse = service.getResponse();


.................................

                
		HttpRequestService.newInstance()
			.setEndPoint(APICREDENTIALS.get(credentail).EndPoint__c)
			.setContentType('application/json')
			.setAuthorization('Bearer ' + accessToken)
			.setBody(body)
			.doPost();

            ........................


             HttpRequestService.newInstance()
			.setEndPoint(APICREDENTIALS.get(credentail).EndPoint__c)
			.setContentType('application/json')
			.setBody(body)
			.doPost()
			.getStringBodyToken('access_token');
 */