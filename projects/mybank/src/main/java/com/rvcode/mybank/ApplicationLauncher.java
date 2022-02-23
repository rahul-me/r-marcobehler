package com.rvcode.mybank;

import com.rvcode.mybank.web.MyBankServlet;
import org.apache.catalina.Context;
import org.apache.catalina.LifecycleException;
import org.apache.catalina.Wrapper;
import org.apache.catalina.startup.Tomcat;

import javax.servlet.ServletContext;

public class ApplicationLauncher {
    public static void main(String[] args) throws LifecycleException {
        Tomcat tomcat = new Tomcat();
        int serverPort = 8080;
        String systemProperty = System.getProperty("server.port");
        System.out.println("Sys Prp: "+systemProperty);
        if(systemProperty != null){
            serverPort = Integer.valueOf(systemProperty);
            System.out.println(serverPort);
        }
        tomcat.setPort(serverPort);
        tomcat.getConnector();

        Context ctx = tomcat.addContext("", null);
        ServletContext servletContext = ctx.getServletContext();

        Wrapper servlet = Tomcat.addServlet(ctx,"myBankServlet", new MyBankServlet());
        servlet.setLoadOnStartup(1);
        servlet.addMapping("/*");
        tomcat.start();


    }
}