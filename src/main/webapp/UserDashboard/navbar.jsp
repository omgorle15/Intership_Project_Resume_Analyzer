<%

    String name = (String) session.getAttribute("userName");
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-success px-4">
    <div class="container-fluid">
        <span class="navbar-brand fw-bold">
            Resume Analyzer System
        </span>

        <div class="ms-auto text-white">
            Welcome, <%= name %>
        </div>
    </div>
</nav>
