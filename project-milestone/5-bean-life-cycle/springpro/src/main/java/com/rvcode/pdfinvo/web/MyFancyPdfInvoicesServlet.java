package com.rvcode.pdfinvo.web;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.rvcode.pdfinvo.context.PdfInvoicesApplicationConfiguration;
import com.rvcode.pdfinvo.model.Invoice;
import com.rvcode.pdfinvo.service.InvoiceService;
import com.rvcode.pdfinvo.service.UserService;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;


public class MyFancyPdfInvoicesServlet extends HttpServlet {

    private UserService userService;
    private InvoiceService invoiceService;
    private ObjectMapper mapper;

    @Override
    public void init() throws ServletException {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(PdfInvoicesApplicationConfiguration.class);
        ctx.registerShutdownHook();
        this.userService = ctx.getBean(UserService.class);
        this.invoiceService = ctx.getBean(InvoiceService.class);
        this.mapper = ctx.getBean(ObjectMapper.class);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getRequestURI().equalsIgnoreCase("/")) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(
                    "<html>\n" +
                            "<body>\n" +
                            "<h1>Hello World</h1>\n" +
                            "<p>This is my very first, embedded Tomcat, HTML Page!</p>\n" +
                            "</body>\n" +
                            "</html>");
        } else if (request.getRequestURI().equalsIgnoreCase("/invoices")) {
            String json = mapper.writeValueAsString(invoiceService.findAll());
            response.setContentType("application/json;charset=UTF8");
            response.getWriter().print(json);
        }

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getRequestURI().equalsIgnoreCase("/invoices")) {

            String userId = request.getParameter("user_id");
            Integer amount = Integer.parseInt(request.getParameter("amount"));

            Invoice invoice = invoiceService.create(userId, amount);
            String json = mapper.writeValueAsString(invoice);

            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().print(json);

        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}