package com.rvcode.mytodo.web;

import com.rvcode.mytodo.context.MyToDoAppConfiguration;
import com.rvcode.mytodo.service.ToDoService;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;

@WebServlet(urlPatterns = "/todo", loadOnStartup = 1)
public class ToDoServlet extends HttpServlet {

    private ToDoService toDoService;

    @Override
    public void init() throws ServletException {
        super.init();
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(MyToDoAppConfiguration.class);
        toDoService = ctx.getBean(ToDoService.class);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        System.out.println("Get called for todos ");
        String name = (String) request.getAttribute("name");

        //Used to check request and session scope
        if(null == name){
            System.out.println("Parameter name is not available");
        } else {
            System.out.println("Parameter name is available");
        }

        // check if session scope has your value
        String sname = (String) request.getSession().getAttribute("name");
        if(null == sname){
            System.out.println("Name is not available in session");
        } else {
            System.out.println(sname+" Name is available in session");
        }

        request.setAttribute("todos", toDoService.findAll());
        request.getRequestDispatcher("/WEB-INF/view/todo.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("POST is called instead GET");
        String todoname = request.getParameter("todo");
        if(todoname != null) {
            toDoService.add(todoname);
        }
        doGet(request, response);
    }
}
