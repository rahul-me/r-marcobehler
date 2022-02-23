package com.ricky.myfancypdfinvoices;

import org.apache.catalina.Context;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.LifecycleException;
import org.apache.catalina.Wrapper;

public class ApplicationLauncher {
    public static void main(String[] args) throws LifecycleException {
        Tomcat tomcat = new Tomcat();
        tomcat.setPort(8080);
        tomcat.getConnector();

        // code for registering servlet
        Context ctx = tomcat.addContext("", null);
        Wrapper servlet = Tomcat.addServlet(ctx, "myFirstServlet", new MyPdfInvoiceServlet());
        servlet.setLoadOnStartup(1);
        servlet.addMapping("/*");
        //

        tomcat.start();

    }
}