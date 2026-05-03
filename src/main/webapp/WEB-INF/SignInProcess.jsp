<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
String email = request.getParameter("email");
String password = request.getParameter("password");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

boolean isValidUser = false;
String userName = "";

try {

    Class.forName("com.mysql.cj.jdbc.Driver");

    con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jobanalyzer",  
        "root",                                     
        "Omgorle@123"                                    
    );

    String query = "SELECT * FROM users WHERE email=? AND password=?";
    ps = con.prepareStatement(query);
    ps.setString(1, email);
    ps.setString(2, password);

    rs = ps.executeQuery();

    if(rs.next()) {
        isValidUser = true;
        userName = rs.getString("name");

       
        session.setAttribute("userEmail", email);
        session.setAttribute("userName", userName);
    }

} catch(Exception e) {
    out.println("Database Error: " + e.getMessage());
} finally {
    if(rs != null) rs.close();
    if(ps != null) ps.close();
    if(con != null) con.close();
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login Status</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container vh-100 d-flex justify-content-center align-items-center">

<% if(isValidUser) { %>

    <div class="card shadow p-5 text-center" style="width:400px;">
        <h4 class="text-success mb-3">Login Successful</h4>
        <p>Welcome, <strong><%= userName %></strong></p>

        <div class="progress mt-3" style="height:5px;">
            <div id="progressBar" class="progress-bar bg-success" style="width:100%"></div>
        </div>
    </div>

    <script>
        let progress = 100;
        let interval = setInterval(function(){
            progress -= 1;
            document.getElementById("progressBar").style.width = progress + "%";
            if(progress <= 0){
                clearInterval(interval);
                window.location.href = "userDashboard.jsp";
            }
        }, 20);   
    </script>

<% } else { %>

    <div class="card shadow p-5 text-center" style="width:400px;">
        <h4 class="text-danger mb-3"> Invalid Email or Password</h4>
        <a href="SignIn.jsp" class="btn btn-primary mt-3">Try Again</a>
    </div>

<% } %>

</div>

</body>
</html>
