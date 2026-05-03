<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
Integer userId = (Integer) session.getAttribute("userId");

if(userId == null){
    response.sendRedirect("../SignIn.jsp");
    return;
}

Connection con = DBConnection.getConnection();

PreparedStatement ps = con.prepareStatement(
"SELECT u.name, u.email, m.bio, m.photo, m.specialization " +
"FROM users u LEFT JOIN mentor_profile m ON u.id = m.user_id WHERE u.id=?"
);

ps.setInt(1, userId);
ResultSet rs = ps.executeQuery();

String name="", email="", bio="", photo="", specialization="";

if(rs.next()){
    name = rs.getString("name");
    email = rs.getString("email");
    bio = rs.getString("bio");
    photo = rs.getString("photo");
    specialization = rs.getString("specialization");
}

if(specialization == null) specialization="";

rs.close();
ps.close();
con.close();
%>

<!DOCTYPE html>
<html>
<head>
<title>Update Profile</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

<div class="container-fluid">
    <div class="row">

        <!-- Sidebar -->
        <%@ include file="sidebar.jsp" %>

        <!-- Main Content -->
        <div class="col-md-10 mt-5">
            <div class="container">
                <div class="card shadow p-4">

                    <h3 class="mb-4">Update Profile</h3>

                    <form action="../UpdateMentorServlet" method="post" enctype="multipart/form-data">

                        <!-- Name -->
                        <div class="mb-3">
                            <label class="form-label">Name</label>
                            <input type="text" name="name" class="form-control" 
                                   value="<%= name %>" required>
                        </div>

                        <!-- Email -->
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" 
                                   value="<%= email %>" readonly>
                        </div>

                        <!-- Bio -->
                        <div class="mb-3">
                            <label class="form-label">Message / Bio</label>
                            <textarea name="bio" class="form-control" rows="4">
<%= bio == null ? "" : bio %></textarea>
                        </div>

                        <!-- Photo -->
                        <div class="mb-3">
                            <label class="form-label">Profile Photo</label>
                            <input type="file" name="photo" class="form-control">

                            <% if(photo != null && !photo.isEmpty()){ %>
                                <br>
                                <img src="../uploads/<%= photo %>" width="120" class="rounded">
                            <% } %>
                        </div>

                        <hr>

                        <!-- Specialization -->
                        <div class="mb-3">
                            <label class="form-label">Specialization</label><br>

                            <%
                            String[] specializationList = {
                                "Java",
                                "Web Development",
                                "Data Science",
                                "Machine Learning",
                                "UI/UX Design",
                                "Cyber Security",
                                "Cloud Computing",
                                "Android Development"
                            };

                            for(String s : specializationList){
                            %>
                                <input type="checkbox" name="specialization" 
                                       value="<%= s %>"
                                <%= specialization.contains(s) ? "checked" : "" %> >
                                <%= s %> <br>
                            <%
                            }
                            %>
                        </div>

                        <button type="submit" class="btn btn-primary">
                            Update
                        </button>

                    </form>

                </div>
            </div>
        </div>

    </div>
</div>

</body>
</html>