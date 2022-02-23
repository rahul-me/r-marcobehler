package com.mitrais.psms.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = "/saveStuff")
public class StuffJsonController extends HttpServlet {
	
	/**
	 * This has been created to see how servlet can handle JSON request.
	 */
	private static final long serialVersionUID = 4832808527969359132L;

	@Override
	public void doPost(HttpServletRequest req, HttpServletResponse res)  throws ServletException, IOException {
		BufferedReader br = new BufferedReader(new InputStreamReader(req.getInputStream()));
		String json = "";
		String line ="";
		while((line = br.readLine())!=null) {
			json+=line;
		}
		System.out.println("Received: \n"+json);
	}
	
	@Override
	public void doGet(HttpServletRequest req, HttpServletResponse res)  throws ServletException, IOException {
		
	}
}
