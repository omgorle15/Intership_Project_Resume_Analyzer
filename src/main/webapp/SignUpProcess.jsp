<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
String name = request.getParameter("name");
String email = request.getParameter("email");
String password = request.getParameter("password");
String confirmPassword = request.getParameter("confirmPassword");
String role = request.getParameter("role");   // get role from form

if("omgorle5@gmail.com".equalsIgnoreCase(email)){
%>
    <script>
        alert("These email is already Registered ...!");
        window.location="SignUp.jsp";
    </script>
<%
    return;
}



if(password != null && password.equals(confirmPassword)) {

    try(Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO users(name,email,password,role,status) VALUES(?,?,?,?,?)"
        )) {

        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, password);
        ps.setString(4, role);
        ps.setString(5, "pending");  // default status

        int i = ps.executeUpdate();

        if(i > 0){
%>
            <script>
                alert("Registration Successful! Your account is pending approval by Admin.");
                window.location="SignIn.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("Registration Failed!");
                window.location="SignUp.jsp";
            </script>
<%
        }

    } catch(Exception e){
        out.println("Error: " + e.getMessage());
    }

} else {
%>
    <script>
        alert("Passwords do not match!");
        window.location="SignUp.jsp";
    </script>
<%
}
%>