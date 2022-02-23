package com.mitrais.psms.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Method;
import java.util.Enumeration;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = "/checkbox")
public class PassingCheckBox extends HttpServlet {
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		resp.setContentType("text/html");
		RequestDispatcher dis = req.getRequestDispatcher("PassingCheckboxData.html");
		dis.forward(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String mflag = req.getParameter("maths");
		String pflag = req.getParameter("physics");
		String chemflag = req.getParameter("chemistry");

		String[] subjects = req.getParameterValues("subjects");

		PrintWriter out = resp.getWriter();
		out.println("<html><body><ul>");

		out.println("<li>Math flag: " + mflag + "</li><li>Phy Flag: " + pflag + "</li>" + "<li>Chem Flag: " + chemflag
				+ "</li>");

		for (String sub : subjects) {
			out.println("<li>" + sub + "</li>");
		}
		out.println("</ul></body></html>");
		
		System.out.println("Auth Type: "+req.getAuthType());
		System.out.println("Content Type: "+req.getContentType());
		System.out.println("Context Path: "+req.getContextPath());
		System.out.println("Protocol: "+req.getProtocol());
		System.out.println("Query String: "+req.getQueryString());
		System.out.println("Remote Address of Clinet: "+req.getRemoteAddr());
		System.out.println("Fully qualified Name of Clinet: "+req.getRemoteHost());
		System.out.println("Request URI-Portion of URL from port to query string: "+req.getRequestURI());
		
		Enumeration<String> names = req.getHeaderNames();
		
		while(names.hasMoreElements()) {
			String pName = names.nextElement();
			String pVal = req.getHeader(pName);
			System.out.println("Header Name: "+pName+", its value: "+pVal);
		}
		
		
		out.flush();		
	}
	
	
}
