<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
Integer id = (Integer) session.getAttribute("userId");
String role = (String) session.getAttribute("userRole");

if(id == null || !"mentor".equalsIgnoreCase(role)){
    response.sendRedirect("../SignIn.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mentor Profile</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">

<style>
body{
    background:#f4f6f9;
}
.profile-card{
    border-radius:20px;
}
.profile-img{
    width:160px;
    height:160px;
    border-radius:50%;
    object-fit:cover;
    border:5px solid #0d6efd;
}
.badge-custom{
    background:#0d6efd;
    margin:3px;
}
.info-box{
    background:#ffffff;
    padding:15px;
    border-radius:15px;
    box-shadow:0 3px 10px rgba(0,0,0,0.05);
}
</style>
</head>

<body>

<div class="container-fluid">
<div class="row">

    <!-- Sidebar -->
    <%@ include file="sidebar.jsp" %>

    <!-- Main Content -->
    <div class="col-md-10 mt-5">

        <div class="container">
        <div class="card shadow-lg profile-card p-4">

        <h3 class="text-center mb-4 text-primary">
        <i class="fa fa-user-tie"></i> Mentor Profile
        </h3>

<%
try{
    Connection con = DBConnection.getConnection();

    PreparedStatement ps = con.prepareStatement(
        "SELECT u.name, u.email, u.role, " +
        "m.bio, m.photo, m.specialization " +
        "FROM users u " +
        "LEFT JOIN mentor_profile m ON u.id = m.user_id " +
        "WHERE u.id=?"
    );

    ps.setInt(1, id);
    ResultSet rs = ps.executeQuery();

    if(rs.next()){

        String name = rs.getString("name");
        String email = rs.getString("email");
        String userRole = rs.getString("role");
        String bio = rs.getString("bio");
        String photo = rs.getString("photo");
        String specialization = rs.getString("specialization");
%>

<div class="row">

    <!-- LEFT SIDE -->
    <div class="col-md-4 text-center">
        <% if(photo != null && !photo.isEmpty()){ %>
            <img src="../uploads/<%= photo %>" class="profile-img mb-3">
        <% } else { %>
            <i class="fa fa-user-circle fa-8x text-secondary mb-3"></i>
        <% } %>

        <h4><%= name %></h4>
        <p class="text-muted"><%= email %></p>

        <span class="badge bg-success">
            <%= userRole %>
        </span>
    </div>

    <!-- RIGHT SIDE -->
    <div class="col-md-8">

        <!-- Bio -->
        <div class="info-box mb-3">
            <h5><i class="fa fa-quote-left text-primary"></i> About</h5>
            <p>
                <%= (bio != null && !bio.isEmpty()) ? bio : "No bio added yet." %>
            </p>
        </div>

        <!-- Specialization -->
        <div class="info-box mb-3">
            <h5><i class="fa fa-star text-primary"></i> Specialization</h5>

            <%
            if(specialization != null && !specialization.isEmpty()){
                String[] specs = specialization.split(",");
                for(String s : specs){
            %>
                <span class="badge badge-custom"><%= s %></span>
            <%
                }
            } else {
            %>
                Not Set
            <%
            }
            %>
        </div>

        <a href="updateMentor.jsp" class="btn btn-primary mt-2">
            <i class="fa fa-edit"></i> Edit Profile
        </a>

    </div>

</div>

<%
    } else {
%>
    <div class="alert alert-warning text-center">
        Profile data not found.
    </div>
<%
    }

    rs.close();
    ps.close();
    con.close();

}catch(Exception e){
%>
    <div class="alert alert-danger text-center">
        <%= e.getMessage() %>
    </div>
<%
}
%>

        </div>
        </div>

    </div>

</div>
</div>

</body>
</html>