package com.rvcode.mytodo.web;

import com.rvcode.mytodo.context.MyToDoAppConfiguration;
import com.rvcode.mytodo.service.LoginService;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebInitParam;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Enumeration;

@WebServlet(urlPatterns = "/login.do", loadOnStartup = 1,
initParams = @WebInitParam(name="adminEmail", value = "rahul@mail.rvcode"))
public class LoginServlet extends HttpServlet {

    private LoginService loginService;

    @Override
    public void init() throws ServletException {
        super.init();
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(MyToDoAppConfiguration.class);
        loginService = ctx.getBean(LoginService.class);
        System.out.println(loginService);
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // Servlet init parameters
        ServletConfig servletConfig = getServletConfig();
        System.out.println("My Init Parameters for this servlet");
        String adminEmail = servletConfig.getInitParameter("adminEmail");
        System.out.println("Admin Email "+adminEmail);
        request.setAttribute("adminEmail", adminEmail);
        //...

        // Servlet context parameters
        ServletContext con = getServletContext();
        Enumeration<String> contextParamNames = con.getInitParameterNames();
        while(contextParamNames.hasMoreElements()){
            String name = contextParamNames.nextElement();
            System.out.println(name+" "+con.getInitParameter(name));
        }
        //...

        request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String password = request.getParameter("password");

        if(loginService.isAuthorised(password)) {
            request.getSession().setAttribute("name", request.getParameter("name"));
            request.setAttribute("name", request.getParameter("name"));
            response.sendRedirect("/todo");
        } else {
            request.setAttribute("ifError", "Invalid Credentials. Forbidden");
            request.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(request, response);
        }
    }

}
