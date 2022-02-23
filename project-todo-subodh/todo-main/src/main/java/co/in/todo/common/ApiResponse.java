package co.in.todo.common;

import org.springframework.http.HttpStatus;

public class ApiResponse {

    private HttpStatus status;
    private int code;
    private String message;
    private Object result;

	public ApiResponse() {
		
	}

    public ApiResponse(HttpStatus status, int code, String message, Object result) {
        this.status = status;
        this.code = code;
        this.message = message;
        this.result = result;
    }

	public HttpStatus getStatus() {
		return status;
	}

	public void setStatus(HttpStatus status) {
		this.status = status;
	}

	public int getCode() {
		return code;
	}

	public void setCode(int code) {
		this.code = code;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public Object getResult() {
		return result;
	}

	public void setResult(Object result) {
		this.result = result;
	}
    
    
}