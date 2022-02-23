package com.mitrais.psms.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.mitrais.psms.dao.StuffDao;
import com.mitrais.psms.model.Stuff;

@WebServlet(urlPatterns = {"/index","/save"})
public class StuffController extends HttpServlet {
	
	private StuffDao dao = StuffDao.getInstance();
 
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String action = req.getServletPath();
		switch (action) {
		case "/save":
			System.out.println("action save here");
			save(req, res);
			break;

		default:
			System.out.println("action default here");
			break;
		}
		
	}
		
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		RequestDispatcher dis = req.getRequestDispatcher("NewStuff.jsp");
		dis.forward(req, res);
	}
	
	private void save(HttpServletRequest req, HttpServletResponse res) {
		String name = req.getParameter("name");
		String description = req.getParameter("description");
		int quantity = Integer.parseInt(req.getParameter("quantity"));
		String location = req.getParameter("location");
		
		Stuff stuff = new Stuff(name, description, quantity, location);
		try {
			boolean result = dao.save(stuff);
			if(result)System.out.println("Item saved");
		} catch (SQLException e) {
			e.printStackTrace();
		}
		try {
			req.getRequestDispatcher("result.jsp").forward(req, res);
		} catch (ServletException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		};
		
	}
	
}
