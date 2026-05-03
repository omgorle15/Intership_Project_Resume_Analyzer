<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mentor Management</title>

<!-- Bootstrap 5 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
body{
    background-color:#f4f6f9;
}

.main-content{
    padding:25px;
}

.card-style{
    border-radius:10px;
}

.table thead{
    background:#212529;
    color:white;
}
</style>

</head>
<body>

<div class="container-fluid">
<div class="row">

    <%@ include file="sidebar.jsp" %>

    <!-- MAIN PANEL -->
    <div class="col-md-10 p-0">

        <%@ include file="Topbar.jsp" %>

        <div class="main-content">

            <!-- Page Title -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="fw-bold">Manage Mentors</h4>
            </div>

            <!-- FILTER CARD -->
            <div class="card shadow card-style mb-4">
                <div class="card-body">

                    <form method="get" class="row g-3">

                        <div class="col-md-5">
                            <input type="search" name="search" class="form-control"
                                   placeholder="Search by name or email"
                                   value="<%= request.getParameter("search") == null ? "" : request.getParameter("search") %>">
                        </div>

                        <div class="col-md-4">
                            <select name="status" class="form-select">
                                <option value="">All Status</option>
                                <option value="pending"
                                <% if("pending".equals(request.getParameter("status"))) { %> selected <% } %>>
                                Pending
                                </option>
                                <option value="approved"
                                <% if("approved".equals(request.getParameter("status"))) { %> selected <% } %>>
                                Approved
                                </option>
                                <option value="rejected"
                                <% if("rejected".equals(request.getParameter("status"))) { %> selected <% } %>>
                                Rejected
                                </option>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <button class="btn btn-primary w-100">
                                <i class="bi bi-funnel"></i> Filter
                            </button>
                        </div>

                    </form>

                </div>
            </div>

            <!-- TABLE CARD -->
            <div class="card shadow card-style">
                <div class="card-header bg-dark text-white">
                    Mentor List
                </div>

                <div class="card-body table-responsive">

                    <table class="table table-hover table-bordered align-middle text-center">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>

<%
String search = request.getParameter("search");
String status = request.getParameter("status");

try(Connection con = DBConnection.getConnection()){

    String sql = "SELECT * FROM users WHERE 1=1";

    if(search != null && !search.trim().isEmpty()){
        sql += " AND (name LIKE ? OR email LIKE ?)";
    }

    if(status != null && !status.isEmpty()){
        sql += " AND status = ?";
    }

    sql += " ORDER BY id DESC";

    PreparedStatement ps = con.prepareStatement(sql);

    int index = 1;

    if(search != null && !search.trim().isEmpty()){
        ps.setString(index++, "%" + search + "%");
        ps.setString(index++, "%" + search + "%");
    }

    if(status != null && !status.isEmpty()){
        ps.setString(index++, status);
    }

    ResultSet rs = ps.executeQuery();
    boolean hasData = false;

    while(rs.next()){
        hasData = true;
%>

                            <tr>
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getString("name") %></td>
                                <td><%= rs.getString("email") %></td>
                              
                                <td>
                                    <form action="updateStatusMentor.jsp" method="post">
                                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">

                                        <select name="status"
                                                class="form-select form-select-sm"
                                                onchange="this.form.submit()">

                                            <option value="pending"
                                            <% if("pending".equals(rs.getString("status"))) { %> selected <% } %>>
                                            Pending
                                            </option>

                                            <option value="approved"
                                            <% if("approved".equals(rs.getString("status"))) { %> selected <% } %>>
                                            Approved
                                            </option>

                                            <option value="rejected"
                                            <% if("rejected".equals(rs.getString("status"))) { %> selected <% } %>>
                                            Rejected
                                            </option>

                                        </select>
                                    </form>
                                </td>
                            </tr>

<%
    }

    if(!hasData){
%>
                            <tr>
                                <td colspan="5" class="text-muted">No mentors found</td>
                            </tr>
<%
    }

}catch(Exception e){
%>
                            <tr>
                                <td colspan="5" class="text-danger">
                                    Error: <%= e.getMessage() %>
                                </td>
                            </tr>
<%
}
%>

                        </tbody>
                    </table>

                </div>
            </div>

        </div>
    </div>

</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>