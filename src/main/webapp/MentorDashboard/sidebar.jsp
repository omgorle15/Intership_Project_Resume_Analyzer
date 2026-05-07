<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
.sidebar { height: 100vh; background: linear-gradient(180deg, #1f2937, #111827); position: sticky; top: 0; overflow-y: auto; }
.sidebar .brand { font-size: 1.1rem; font-weight: 700; color: white; padding: 20px 15px 10px; border-bottom: 1px solid #374151; margin-bottom: 10px; }
.sidebar a { color: #cbd5e1; text-decoration: none; padding: 11px 15px; display: flex; align-items: center; gap: 10px; border-radius: 8px; margin: 2px 8px; font-size: .93rem; transition: .2s; }
.sidebar a:hover { background: #374151; color: white; }
.sidebar a.active { background: #2563eb; color: white; }
.sidebar .logout-link { color: #f87171 !important; }
.sidebar .logout-link:hover { background: rgba(248,113,113,.15) !important; }
.sidebar .divider { border-top: 1px solid #374151; margin: 8px 15px; }
</style>

<div class="col-md-2 sidebar p-0 d-flex flex-column">

    <div class="brand text-center">
        <i class="fa fa-chalkboard-teacher me-2"></i>Mentor Panel
    </div>

    <% String currentPage = request.getServletPath(); %>

    <a href="MentorDashboard.jsp" class="<%= currentPage.contains("MentorDashboard") ? "active" : "" %>">
        <i class="fa fa-gauge"></i> Dashboard
    </a>
    <a href="viewProfile.jsp" class="<%= currentPage.contains("viewProfile") ? "active" : "" %>">
        <i class="fa fa-user"></i> View Profile
    </a>
    <a href="updateMentor.jsp" class="<%= currentPage.contains("updateMentor") ? "active" : "" %>">
        <i class="fa fa-edit"></i> Update Profile
    </a>

    <div class="divider"></div>

    <a href="bookTimeSlot.jsp" class="<%= currentPage.contains("bookTimeSlot") || currentPage.contains("addTimeSlot") ? "active" : "" %>">
        <i class="fa fa-clock"></i> Time Slots
    </a>
    <a href="viewUser.jsp" class="<%= currentPage.contains("viewUser") ? "active" : "" %>">
        <i class="fa fa-users"></i> Booked Users
    </a>
    <a href="test.jsp" class="<%= currentPage.contains("test") ? "active" : "" %>">
        <i class="fa fa-history"></i> Session History
    </a>

    <div class="divider"></div>

    <a href="../logout.jsp" class="logout-link">
        <i class="fa fa-sign-out-alt"></i> Logout
    </a>

</div>
