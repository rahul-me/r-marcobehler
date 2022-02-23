package com.mitrais.psms.controller;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = "/names")
public class PrintNameController extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = -9077833680418581997L;
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String fname = req.getParameter("first_name");
		String lname = req.getParameter("last_name");
		
		PrintWriter out = resp.getWriter();
		out.println("<html><body><ul><li>First Name: "+fname+"</li><li>Last Name: "+lname+"</li></ul></body></html>");
		out.flush();
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		super.doPost(req, resp);
	}
	
}
