<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600;700&display=swap" rel="stylesheet">
  
  <title>Dashboard with Background Image</title>
  <style>
    body {
      position: relative;
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      background-color: white;
      background-size: cover;
      background-position: center;
      background-attachment: fixed;
      color: white;
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      align-items: center;
      min-height: 100vh;
      overflow-x: hidden;
    }

    /* Container Fade-in Animation */
    @keyframes fadeIn {
      0% {
        opacity: 0;
        transform: translateY(20px);
      }
      100% {
        opacity: 1;
        transform: translateY(0);
      }
    }

    /* .manage container (form container) */
    .manage {
      position: absolute;
      top: 100px;
      background-color: #fff;
      padding: 30px;
      border-radius: 8px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
      width: 100%;
      max-width: 400px;
      position: relative;
      z-index: 2; /* Ensure it appears above the background */
      margin-top: 150px; /* Adjust to move the form down */
      animation: fadeIn 0.6s ease-out; /* Animation remains intact */
    }

    h1 {
      text-align: center;
      color: #444;
      margin-bottom: 20px;
      font-size: 24px;
      opacity: 0;
      animation: fadeIn 1s ease-out 0.2s forwards;
    }
    h2 {
      text-align: center;
      color: white;
      margin-top: 5px;
      margin-left: -20px;
      font-size: 24px;
      opacity: 0;
      animation: fadeIn 1s ease-out 0.2s forwards;
    }
    .form-group {
      margin-bottom: 20px;
    }

    label {
      font-size: 16px;
      color: #666;
      display: block;
      margin-bottom: 5px;
    }

    input[type="text"] {
      width: 100%;
      padding: 10px;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 16px;
      background-color: #fafafa;
      box-sizing: border-box;
      transition: all 0.3s ease;
    }

    input[type="text"]:focus {
      border-color: #007BFF;
      outline: none;
      background-color: #fff;
    }

    button {
      width: 100%;
      padding: 12px;
      background-color: #007BFF;
      color: #fff;
      font-size: 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      transition: background-color 0.3s ease, transform 0.2s ease;
    }

    button:hover {
      background-color: #0056b3;
      transform: translateY(-2px);
    }

     /* First Navbar */
     .navbar {
  width: 100%;
  overflow: hidden;
  padding: 1px;
  background-color: blue;
}

.navbar a {
  float: right;
  font-size: 16px;
  color: white;
  text-align: center;
  padding: 30px 20px;
  text-decoration: none;
}

.navbar a:hover {
  background-color: blue;
  color: white; /* Change text color to white when hovering */
}

.dropdown {
  float: right;
  overflow: hidden;
}

.dropdown .dropbtn {
  font-size: 16px;
  border: none;
  outline: none;
  color: white;
  padding: 30px 20px;
  background-color: inherit;
  font-family: inherit;
  margin: 0;
}

.dropdown:hover .dropbtn {
  background-color: blue;
  color: white; /* Change text color to white when hovering */
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #f9f9f9;
  min-width: 160px;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 1;
}

.dropdown-content a {
  float: none;
  color: black;
  padding: 12px 16px;
  text-decoration: none;
  display: block;
  text-align: left;
}

.dropdown-content a:hover {
  background-color: #ddd;
  color: white; /* Change text color to white when hovering over dropdown items */
}

.dropdown:hover .dropdown-content {
  display: block;
}

    .navbar-logo {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .navbar-logo img {
      width: 50px; /* Logo size */
      height: auto;
    }

    .navbar-logo h1 {
      font-size: 24px;
      font-style: italic;
      color: black;
      margin: 0;
    }

    /* Background images */
    .bgplane {
      position: absolute;
      top: 80px; /* Keeps the first background image in place */
      width: 100%;
      display: flex;
      background-position: center;
      background-repeat: no-repeat;
      background-size: cover;
      object-fit: contain;
      z-index: -1; /* Ensure the background is behind everything else */
    }

    .skybound {
  position: absolute;
  left: 60px;
  top: -7px;
  height: 60%;  /* Reduced height */
  width: 20%;   /* Reduced width */

}

.name{
  position: absolute;
  left: -420px;
  top: -315px;
  color: black;
  font-style: italic;
}

  </style>
</head>
<body>

  <!-- Navbar with Logo and Skybound Airlines Name -->
  <div class="navbar">
    <div class="navbar-logo">
      
      
    </div>
    <div>
     
      <a href="help.php">Help</a>
      <div class="dropdown">
        <button class="dropbtn">Manage
          <i class="fa fa-caret-down"></i>
        </button>
        <div class="dropdown-content">
          
          <a href="bookaflight.php">Book a flight</a>
          <a href="flightstatus.php">Flight Status</a>
        </div>
      </div>
    </div>
  </div>

  <!-- Background Images -->
  <div class="skybound"><img src="img/logo.png" alt="Image"></div>
  <div class="bgplane"><img src="img/airplane.jpg" alt="Image"></div>

  <!-- .manage Container (Form Section) -->
  <div class="manage">
    <h1>Manage Your Booking</h1>
        <form action="#" method="post">
          
        <div class="form-group">
        <label for="Booking-reference">Booking Reference</label>
        <input type="text" id="Booking-reference" name="Booking-reference" required>
        </div>

        <div class="form-group">
        <label for="Last-name">Last Name</label>
        <input type="text" id="Last-name" name="Last-name" required>
      </div>
      <div class="form-group">
        <button type="submit">Manage Booking</button>
      </div>

      <div class ="name">
      <h2> Skybound Airlines </h2> </div>
      </div>

    </form>
  </div>

</body>
</html>
