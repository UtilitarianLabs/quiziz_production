global class QuizizzCalls {

	@future(callout=true)
	public static void doCallout(String account)
	{
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        // Set the endpoint URL.
        System.debug(account);
        String endpoint = 'https://dev.quizizz.com/_api/sfInt/payment/sfcpq/hooks';
        request.setEndPoint(endpoint);
        // Set the HTTP verb to POST.
        request.setMethod('POST');
        
        // Set the request body
        request.setBody(account);
        
        // Set the Request Header
        request.setHeader('content-type', 'application/json');
        
        try {
            // Send the HTTP request and get the response.
            response = new HTTP().send(request);
            System.debug(response.toString());
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
        }
	}
}